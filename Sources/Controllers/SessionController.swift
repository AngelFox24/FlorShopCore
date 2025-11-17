import Fluent
import Vapor

struct SessionController: RouteCollection {
    let syncManager: SyncManager
    let validator: FlorShopAuthValitator
    func boot(routes: any RoutesBuilder) throws {
        let session = routes.grouped("session")
//        session.post("logIn", use: self.logIn)
        session.post("register", use: self.register)
    }
//    @Sendable
//    func logIn(req: Request) async throws -> SessionConfig {
//        let logInParameters = try req.content.decode(LogInParameters.self)
//        let employee = try await Employee.query(on: req.db)
//            .filter(\.$user == logInParameters.username)
//            .with(\.$subsidiary)
//            .all()
//            .first
//        guard let employeeId = employee?.id, let subsidiaryId = employee?.subsidiary.id else {
//            throw Abort(.badRequest, reason: "Empleado no encontrado")
//        }
//        let subsidiary = try await Subsidiary.query(on: req.db)
//            .filter(\.$id == subsidiaryId)
//            .with(\.$company)
//            .all()
//            .first
//        guard let companyId = subsidiary?.company.id else {
//            throw Abort(.badRequest, reason: "Subsidiaria no encontrada")
//        }
//        return SessionConfig(
//            companyId: companyId,
//            subsidiaryId: subsidiaryId,
//            employeeId: employeeId
//        )
//    }
    //POST: /session/register
    @Sendable
    func register(req: Request) async throws -> SessionConfig {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        let registerParameters = try req.content.decode(RegisterParameters.self)
        guard try await Company.query(on: req.db).first() == nil else {
            throw Abort(.badRequest, reason: "No se puede registrar mas de una empresa")
        }
        let oldGlobalToken: Int64 = await self.syncManager.getLastGlobalToken()
        let oldBranchToken: Int64 = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        let sessionConfig = try await req.db.transaction { transaction -> SessionConfig in
            let companyCic = payload.companyCic
            let subsidiaryCic = payload.subsidiaryCic
            let employeeCic = payload.sub.value
            //Registramos la compañia
            let newCompany = Company(
                companyCic: companyCic,
                companyName: registerParameters.company.companyName,
                ruc: registerParameters.company.ruc,
                syncToken: await syncManager.nextGlobalToken()
            )
            try await newCompany.save(on: transaction)
            guard let companyId = newCompany.id else {
                throw Abort(.internalServerError, reason: "companyId no pudo ser obtenido")
            }
            //Registramos la subsidiaria
            let newSubsidiary = Subsidiary(
                subsidiaryCic: subsidiaryCic,
                name: registerParameters.subsidiary.name,
                imageUrl: registerParameters.subsidiary.imageUrl,
                syncToken: await syncManager.nextGlobalToken(),
                companyID: companyId
            )
            try await newSubsidiary.save(on: transaction)
            guard let subsidiaryId = newSubsidiary.id else {
                throw Abort(.internalServerError, reason: "subsidiaryId no pudo ser obtenido")
            }
            //Registramos al empleado
            let newEmployee = Employee(
                employeeCic: employeeCic,
                user: registerParameters.employee.user,
                name: registerParameters.employee.name,
                lastName: registerParameters.employee.lastName,
                email: registerParameters.employee.email,
                phoneNumber: registerParameters.employee.phoneNumber,
                role: registerParameters.employee.role,
                active: registerParameters.employee.active,
                imageUrl: registerParameters.employee.imageUrl,
                syncToken: await syncManager.nextBranchToken(subsidiaryCic: payload.subsidiaryCic),
                subsidiaryID: subsidiaryId
            )
            try await newEmployee.save(on: transaction)
            guard let employeeId = newEmployee.id else {
                throw Abort(.internalServerError, reason: "employeeId no pudo ser obtenido")
            }
            return SessionConfig(
                companyId: companyId,
                subsidiaryId: subsidiaryId,
                employeeId: employeeId
            )
        }
        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return sessionConfig
    }
}
