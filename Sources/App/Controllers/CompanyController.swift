import Fluent
import Vapor

struct CompanyController: RouteCollection {
    let syncManager: SyncManager
    func boot(routes: any RoutesBuilder) throws {
        let companies = routes.grouped("companies")
//        companies.post("sync", use: self.sync)
        companies.post(use: self.save)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        let companyDTO = try req.content.decode(CompanyInputDTO.self).clean()
        try self.validateInput(companyDTO: companyDTO)
        let responseText: String
        
        if let companyId = companyDTO.id { //Update: If the client send Id is for update
            guard let company = try await Company.find(companyId, on: req.db) else {
                throw Abort(.badRequest, reason: "La compañia no existe para actualizar")
            }
            guard !companyDTO.isEqual(to: company) else {
                return DefaultResponse(message: "Not Updated, is equal")
            }
            company.companyName = companyDTO.companyName
            company.ruc = companyDTO.ruc
            company.syncToken = await syncManager.nextToken()
            try await company.update(on: req.db)
            responseText = "Updated"
        } else { //Create: If client don't send Id is for Create a new item
            guard try await !self.validateExist(dto: companyDTO, db: req.db) else {
                throw Abort(.badRequest, reason: "El nombre o el RUC de la compañia ya existen")
            }
            let companyNew = Company(
                id: UUID(),
                companyName: companyDTO.companyName,
                ruc: companyDTO.ruc,
                syncToken: await syncManager.nextToken()
            )
            try await companyNew.save(on: req.db)
            responseText = "Created"
        }
        await syncManager.sendSyncData() //Se envia un mensaje a todos para que soncronizen.
        return DefaultResponse(message: responseText)
    }
    private func validateInput(companyDTO: CompanyInputDTO) throws {
        guard companyDTO.companyName != "" else {
            throw Abort(.badRequest, reason: "El nombre de la compañia no puede estar vacio")
        }
        guard companyDTO.ruc != "" else {
            throw Abort(.badRequest, reason: "El RUC de la compañia no puede estar vacio")
        }
    }
    private func validateExist(dto: CompanyInputDTO, db: any Database) async throws -> Bool {
        let companies = try await Company.query(on: db)
            .group(.or) { or in
                or.filter(\.$companyName == dto.companyName)
                or.filter(\.$ruc == dto.ruc)
            }
            .limit(1)
            .all()
        return !companies.isEmpty
    }
}
