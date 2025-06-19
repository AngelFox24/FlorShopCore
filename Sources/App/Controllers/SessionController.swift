import Fluent
import Vapor

struct SessionController: RouteCollection {
    let syncManager: SyncManager
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
    func register(req: Request) async throws -> DefaultResponse {
        let registerParameters = try req.content.decode(RegisterParameters.self)
        guard try await Company.query(on: req.db).first() != nil else {
            throw Abort(.badRequest, reason: "No se puede registrar mas de una empresa")
        }
        try await req.db.transaction { transaction in
            //Registramos la compañia
            let companyId = UUID()
            let newCompany = Company(
                id: companyId,
                companyName: registerParameters.company.companyName,
                ruc: registerParameters.company.ruc
            )
            try await newCompany.save(on: transaction)
            //Registramos la imagen de la subsidiaria
            let subsidiaryImageId = UUID()
            let newSubsidiaryImage = ImageUrl(
                id: subsidiaryImageId,
                imageUrl: registerParameters.subsidiaryImage.imageUrl,
                imageHash: registerParameters.subsidiaryImage.imageHash
            )
            try await newSubsidiaryImage.save(on: transaction)
            //Registramos la subsidiaria
            let subsidiaryId = UUID()
            let newSubsidiary = Subsidiary(
                id: subsidiaryId,
                name: registerParameters.subsidiary.name,
                companyID: companyId,
                imageUrlID: subsidiaryImageId
            )
            try await newSubsidiary.save(on: transaction)
            //Registramos la imagen del empleado
            let employeeImageId = UUID()
            let newEmployeeImage = ImageUrl(
                id: employeeImageId,
                imageUrl: registerParameters.subsidiaryImage.imageUrl,
                imageHash: registerParameters.subsidiaryImage.imageHash
            )
            try await newEmployeeImage.save(on: transaction)
            //Registramos al empleado
            let employeeId = UUID()
            let newEmployee = Employee(
                id: employeeId,
                user: registerParameters.employee.user,
                name: registerParameters.employee.name,
                lastName: registerParameters.employee.lastName,
                email: registerParameters.employee.email,
                phoneNumber: registerParameters.employee.phoneNumber,
                role: registerParameters.employee.role,
                active: registerParameters.employee.active,
                subsidiaryID: subsidiaryId,
                imageUrlID: employeeImageId
            )
            try await newEmployee.save(on: transaction)
        }
        await syncManager.updateLastSyncDate(to: [.company, .subsidiary, .image, .employee])
        return DefaultResponse(message: "Created")
    }
}
