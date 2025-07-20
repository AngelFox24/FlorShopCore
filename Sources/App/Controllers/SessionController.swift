import Fluent
import Vapor

struct SessionController: RouteCollection {
    let syncManager: SyncManager
    let imageUrlService: ImageUrlService
    func boot(routes: any RoutesBuilder) throws {
        let session = routes.grouped("session")
        session.post("logIn", use: self.logIn)
        session.post("register", use: self.register)
    }
    @Sendable
    func logIn(req: Request) async throws -> SessionConfig {
        let logInParameters = try req.content.decode(LogInParameters.self)
        let employee = try await Employee.query(on: req.db)
            .filter(\.$user == logInParameters.username)
            .with(\.$subsidiary)
            .all()
            .first
        guard let employeeId = employee?.id, let subsidiaryId = employee?.subsidiary.id else {
            throw Abort(.badRequest, reason: "Empleado no encontrado")
        }
        let subsidiary = try await Subsidiary.query(on: req.db)
            .filter(\.$id == subsidiaryId)
            .with(\.$company)
            .all()
            .first
        guard let companyId = subsidiary?.company.id else {
            throw Abort(.badRequest, reason: "Subsidiaria no encontrada")
        }
        return SessionConfig(
            companyId: companyId,
            subsidiaryId: subsidiaryId,
            employeeId: employeeId
        )
    }
    @Sendable
    func register(req: Request) async throws -> SessionConfig {
        let registerParameters = try req.content.decode(RegisterParameters.self)
        guard try await Company.query(on: req.db).first() == nil else {
            throw Abort(.badRequest, reason: "No se puede registrar mas de una empresa")
        }
        let sessionConfig = try await req.db.transaction { transaction -> SessionConfig in
            let companyId = UUID()
            let subsidiaryId = UUID()
            let employeeId = UUID()
            let subsidiaryImageId = try await imageUrlService.save(
                db: transaction,
                imageUrlServerDto: registerParameters.subsidiary.imageUrl,
                syncToken: syncManager.nextToken()
            )
            let employeeImageId = try await imageUrlService.save(
                db: transaction,
                imageUrlServerDto: registerParameters.employee.imageUrl,
                syncToken: syncManager.nextToken()
            )
            //Registramos la compañia
            let newCompany = Company(
                id: companyId,
                companyName: registerParameters.company.companyName,
                ruc: registerParameters.company.ruc,
                syncToken: await syncManager.nextToken()
            )
            try await newCompany.save(on: transaction)
            //Registramos la subsidiaria
            let newSubsidiary = Subsidiary(
                id: subsidiaryId,
                name: registerParameters.subsidiary.name,
                syncToken: await syncManager.nextToken(),
                companyID: companyId,
                imageUrlID: subsidiaryImageId
            )
            try await newSubsidiary.save(on: transaction)
            //Registramos al empleado
            let newEmployee = Employee(
                id: employeeId,
                user: registerParameters.employee.user,
                name: registerParameters.employee.name,
                lastName: registerParameters.employee.lastName,
                email: registerParameters.employee.email,
                phoneNumber: registerParameters.employee.phoneNumber,
                role: registerParameters.employee.role,
                active: registerParameters.employee.active,
                syncToken: await syncManager.nextToken(),
                subsidiaryID: subsidiaryId,
                imageUrlID: employeeImageId
            )
            try await newEmployee.save(on: transaction)
            return SessionConfig(
                companyId: companyId,
                subsidiaryId: subsidiaryId,
                employeeId: employeeId
            )
        }
        await syncManager.sendSyncData()
        return sessionConfig
    }
}
