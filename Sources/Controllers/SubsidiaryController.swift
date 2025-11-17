import Fluent
import FlorShopDTOs
import Vapor

struct SubsidiaryController: RouteCollection {
    let syncManager: SyncManager
    let validator: FlorShopAuthValitator
    func boot(routes: any RoutesBuilder) throws {
        let subsidiaries = routes.grouped("subsidiaries")
        subsidiaries.post(use: self.save)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        let subsidiaryDTO = try req.content.decode(SubsidiaryServerDTO.self).clean()
        try self.validateInput(dto: subsidiaryDTO)
        let oldGlobalToken: Int64 = await self.syncManager.getLastGlobalToken()
        let oldBranchToken: Int64 = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        let responseString: String = try await req.db.transaction { transaction -> String in
            if let subsidiary = try await Subsidiary.findSubsidiary(subsidiaryCic: subsidiaryDTO.subsidiaryCic, on: transaction) {
                guard !subsidiaryDTO.isEqual(to: subsidiary) else {
                    throw Abort(.badRequest, reason: "Not Updated, is equal")
                }
                //Update
                guard try await !Subsidiary.nameExist(name: subsidiaryDTO.name, on: transaction) else {
                    throw Abort(.badRequest, reason: "La subsidiaria con este nombre ya existe")
                }
                subsidiary.name = subsidiaryDTO.name
                subsidiary.imageUrl = subsidiaryDTO.imageUrl
                subsidiary.syncToken = await self.syncManager.nextGlobalToken()
                try await subsidiary.update(on: transaction)
                return ("Updated")
            } else {//CREATE
                guard try await !Subsidiary.nameExist(name: subsidiaryDTO.name, on: transaction) else {
                    throw Abort(.badRequest, reason: "La subsidiaria con este nombre ya existe")
                }
                guard let companyId = try await Company.findCompany(companyCic: payload.companyCic, on: transaction)?.id else {
                    throw Abort(.badRequest, reason: "La compañia no existe existe")
                }
                let subsidiaryNew = Subsidiary(
                    subsidiaryCic: UUID().uuidString,
                    name: subsidiaryDTO.name,
                    imageUrl: subsidiaryDTO.imageUrl,
                    syncToken: await syncManager.nextGlobalToken(),
                    companyID: companyId
                )
                try await subsidiaryNew.save(on: transaction)
                return ("Created")
            }
        }
        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return DefaultResponse(message: responseString)
    }
    private func validateInput(dto: SubsidiaryServerDTO) throws {
        guard dto.name != "" else {
            throw Abort(.badRequest, reason: "El nombre de la subsidiaria no puede estar vacio")
        }
    }
    private func getSubsidiary(dto: SubsidiaryServerDTO, db: any Database) async throws -> Subsidiary? {
        return try await Subsidiary.query(on: db)
            .filter(\.$name == dto.name)
            .limit(1)
            .first()
    }
//    private func subsidiaryNameExist(subsidiaryDTO: SubsidiaryServerDTO, db: any Database) async throws -> Bool {
//        let query = try await Subsidiary.query(on: db)
//            .group(.and) { and in
//                and.filter(\.$name == subsidiaryDTO.name)
//                if let subsidiaryId = subsidiaryDTO.id {
//                    and.filter(\.$id != subsidiaryId)
//                }
//            }
//            .limit(1)
//            .first()
//        if query != nil {
//            return true
//        } else {
//            return false
//        }
//    }
}
