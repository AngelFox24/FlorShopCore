import Fluent
import Vapor
import FlorShopDTOs

struct SessionController: RouteCollection {
//    let syncManager: SyncManager
    let validator: FlorShopAuthValitator
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
        let registerParameters = try req.content.decode(RegisterParameters.self)
        guard try await Company.query(on: req.db).first() == nil else {
            throw Abort(.badRequest, reason: "No se puede registrar mas de una empresa")
        }
//        let oldGlobalToken: Int64 = await self.syncManager.getLastGlobalToken()
//        let oldBranchToken: Int64 = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        try await req.db.transaction { transaction in
            let companyCic = payload.companyCic
            let subsidiaryCic = payload.subsidiaryCic
            let employeeCic = payload.sub.value
            //Registramos la compañia
            let newCompany = Company(
                companyCic: companyCic,
                companyName: registerParameters.company.companyName,
                ruc: registerParameters.company.ruc
//                syncToken: await syncManager.nextGlobalToken()
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
//                syncToken: await syncManager.nextGlobalToken(),
                companyID: companyId
            )
            try await newSubsidiary.save(on: transaction)
            guard let subsidiaryId = newSubsidiary.id else {
                throw Abort(.internalServerError, reason: "subsidiaryId no pudo ser obtenido")
            }
            //Registramos al empleado
            let newEmployee = Employee(
                employeeCic: employeeCic,
                name: registerParameters.employee.name,
                lastName: registerParameters.employee.lastName,
                email: registerParameters.employee.email,
                phoneNumber: registerParameters.employee.phoneNumber,
                imageUrl: registerParameters.employee.imageUrl,
//                syncToken: await syncManager.nextGlobalToken(),
                companyID: companyId
            )
            try await newEmployee.save(on: transaction)
            guard let employeeId = newEmployee.id else {
                throw Abort(.internalServerError, reason: "Employee id no encontrado")
            }
            let newEmployeeSubsidiary = EmployeeSubsidiary(
                role: registerParameters.employee.role,
                active: registerParameters.employee.active,
//                syncToken: await syncManager.nextBranchToken(subsidiaryCic: payload.subsidiaryCic),
                subsidiaryID: subsidiaryId,
                employeeID: employeeId
            )
            try await newEmployeeSubsidiary.save(on: transaction)
        }
//        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return DefaultResponse(code: 200, message: "ok")
    }
}
