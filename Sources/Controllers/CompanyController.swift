import Fluent
import FlorShopDTOs
import Vapor

struct CompanyController: RouteCollection {
//    let syncManager: SyncManager
    let validator: FlorShopAuthValitator
    let florShopAuthProvider: FlorShopAuthProvider
    func boot(routes: any RoutesBuilder) throws {
        let companies = routes.grouped("companies")
        companies.get(use: self.test)
        companies.post(use: self.save)
    }
    @Sendable
    func test(req: Request) async throws -> Response {
        return Response(status: .ok, body: "Ok")
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload: ScopedTokenPayload = try await validator.verifyToken(token, client: req.client)
        let companyDTO = try req.content.decode(CompanyServerDTO.self).clean()
        try companyDTO.validate()
        let responseText: String
        
//        let oldGlobalToken: Int64 = await self.syncManager.getLastGlobalToken()
//        let oldBranchToken: Int64 = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        if let company = try await Company.findCompany(companyCic: payload.companyCic, on: req.db) {
            guard !companyDTO.isEqual(to: company) else {
                return DefaultResponse(message: "Not Updated, is equal")
            }
            //TODO: Segregate this in a function
            let internalToken = try await TokenService.generateInternalToken(scopedToken: payload, req: req)
            try await self.florShopAuthProvider.updateCompany(request: companyDTO, internalToken: internalToken)
            company.companyName = companyDTO.companyName
            company.ruc = companyDTO.ruc
//            company.syncToken = await syncManager.nextGlobalToken()
            try await company.update(on: req.db)
            responseText = "Updated"
        } else {
            responseText = "Only one company per server"
        }
//        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return DefaultResponse(message: responseText)
    }
}

extension CompanyServerDTO {
    func validate() throws {
        guard self.companyName != "" else {
            throw Abort(.badRequest, reason: "El nombre de la compañia no puede estar vacio")
        }
        guard self.ruc != "" else {
            throw Abort(.badRequest, reason: "El RUC de la compañia no puede estar vacio")
        }
    }
}
