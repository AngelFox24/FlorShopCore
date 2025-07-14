import Fluent
import Vapor

struct SubsidiaryController: RouteCollection {
    let syncManager: SyncManager
    let imageUrlService: ImageUrlService
    func boot(routes: any RoutesBuilder) throws {
        let subsidiaries = routes.grouped("subsidiaries")
        subsidiaries.post(use: self.save)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        let subsidiaryDTO = try req.content.decode(SubsidiaryInputDTO.self).clean()
        try self.validateInput(dto: subsidiaryDTO)
        //Las imagenes se guardan por separado
        let responseString: String = try await req.db.transaction { transaction -> String in
            let imageId = try await imageUrlService.save(
                db: transaction,
                imageUrlInputDto: subsidiaryDTO.imageUrl,
                syncToken: syncManager.nextToken()
            )
            if let subsidiaryId = subsidiaryDTO.id {//UPDATE
                guard let subsidiary = try await Subsidiary.find(subsidiaryId, on: transaction) else {
                    throw Abort(.badRequest, reason: "La subsidiaria no existe para actualizar")
                }
                guard !subsidiaryDTO.isEqual(to: subsidiary) else {
                    throw Abort(.badRequest, reason: "Not Updated, is equal")
                }
                //Update
                guard try await !subsidiaryNameExist(subsidiaryDTO: subsidiaryDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "La subsidiaria con este nombre ya existe")
                }
                subsidiary.name = subsidiaryDTO.name
                subsidiary.$imageUrl.id = imageId
                try await subsidiary.update(on: transaction)
                return ("Updated")
            } else {//CREATE
                guard try await !subsidiaryNameExist(subsidiaryDTO: subsidiaryDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "La subsidiaria con este nombre ya existe")
                }
                guard let companyId = try await Company.find(subsidiaryDTO.companyID, on: transaction)?.id else {
                    throw Abort(.badRequest, reason: "La compañia no existe existe")
                }
                let subsidiaryNew = Subsidiary(
                    id: UUID(),
                    name: subsidiaryDTO.name,
                    syncToken: await syncManager.nextToken(),
                    companyID: companyId,
                    imageUrlID: imageId
                )
                try await subsidiaryNew.save(on: transaction)
                return ("Created")
            }
        }
        await syncManager.sendSyncData() //Se envia un mensaje a todos para que soncronizen.
        return DefaultResponse(message: responseString)
    }
    private func validateInput(dto: SubsidiaryInputDTO) throws {
        guard dto.name != "" else {
            throw Abort(.badRequest, reason: "El nombre de la subsidiaria no puede estar vacio")
        }
    }
    private func getSubsidiary(dto: SubsidiaryInputDTO, db: any Database) async throws -> Subsidiary? {
        return try await Subsidiary.query(on: db)
            .filter(\.$name == dto.name)
            .limit(1)
            .first()
    }
    private func subsidiaryNameExist(subsidiaryDTO: SubsidiaryInputDTO, db: any Database) async throws -> Bool {
        let query = try await Subsidiary.query(on: db)
            .group(.and) { and in
                and.filter(\.$name == subsidiaryDTO.name)
                if let subsidiaryId = subsidiaryDTO.id {
                    and.filter(\.$id != subsidiaryId)
                }
            }
            .limit(1)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
}
