import Fluent
import Vapor
import FlorShopDTOs

struct SessionController: RouteCollection {
    let validator: FlorShopAuthValitator
    let authProvider: FlorShopAuthProvider
    func boot(routes: any RoutesBuilder) throws {
        let session = routes.grouped("session")
//        session.post("logIn", use: self.logIn)
        session.post("register", use: self.register)
    }
    //POST: /session/register
    @Sendable
    func register(req: Request) async throws -> DefaultResponse {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        //Obtenemos los datos de FlorShopAuth
        let internalToken = try await TokenService.generateInternalToken(scopedToken: payload, req: req)
        let initialData = try await self.authProvider.getInitialData(subsidiaryCic: payload.subsidiaryCic, internalToken: internalToken)
        try await req.db.transaction { transaction in
            let companyCic = payload.companyCic
            let subsidiaryCic = payload.subsidiaryCic
            let employeeCic = payload.sub.value
            //Registramos la compañia
            let newCompany = Company(
                companyCic: companyCic,
                companyName: initialData.company.companyName,
                ruc: initialData.company.ruc
            )
            try await newCompany.save(on: transaction)
            guard let companyId = newCompany.id else {
                throw Abort(.internalServerError, reason: "companyId no pudo ser obtenido")
            }
            //Registramos la subsidiaria
            let newSubsidiary = Subsidiary(
                subsidiaryCic: subsidiaryCic,
                name: initialData.subsidiary.name,
                imageUrl: initialData.subsidiary.imageUrl,
                companyCic: companyCic,
                companyID: companyId
            )
            try await newSubsidiary.save(on: transaction)
            guard let subsidiaryId = newSubsidiary.id else {
                throw Abort(.internalServerError, reason: "subsidiaryId no pudo ser obtenido")
            }
        }
        return DefaultResponse(code: 200, message: "ok")
    }
}
