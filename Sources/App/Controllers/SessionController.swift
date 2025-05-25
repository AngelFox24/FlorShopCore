import Fluent
import Vapor

struct SessionController: RouteCollection {
    let syncManager: SyncManager
    func boot(routes: any RoutesBuilder) throws {
        let session = routes.grouped("session")
        session.post("logIn", use: self.logIn)
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
}
