import Fluent
import FlorShopDTOs
import Vapor

struct EmployeeController: RouteCollection {
    let syncManager: SyncManager
    let validator: FlorShopAuthValitator
    func boot(routes: any RoutesBuilder) throws {
        let employees = routes.grouped("employees")
        employees.post(use: self.save)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        let employeeDTO = try req.content.decode(EmployeeServerDTO.self)
        let oldGlobalToken: Int64 = await self.syncManager.getLastGlobalToken()
        let oldBranchToken: Int64 = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        let responseString: String = try await req.db.transaction { transaction -> String in
            if let employee = try await Employee.findEmployee(employeeCic: employeeDTO.employeeCic, on: transaction) {
                //Update
                if employee.user != employeeDTO.user {
                    guard try await !employeeUserNameExist(employeeDTO: employeeDTO, db: transaction) else {
                        throw Abort(.badRequest, reason: "El nombre de usuario ya existe")
                    }
                    employee.user = employeeDTO.user
                }
                if employee.name != employeeDTO.name || employee.lastName != employeeDTO.lastName {
                    guard try await !employeeFullNameExist(employeeDTO: employeeDTO, db: transaction) else {
                        throw Abort(.badRequest, reason: "El nombre y apellido del empleado ya existe")
                    }
                    employee.name = employeeDTO.name
                    employee.lastName = employeeDTO.lastName
                }
                employee.email = employeeDTO.email
                employee.phoneNumber = employeeDTO.phoneNumber
                employee.role = employeeDTO.role
                employee.active = employeeDTO.active
                employee.imageUrl = employeeDTO.imageUrl
                employee.syncToken = await syncManager.nextBranchToken(subsidiaryCic: payload.subsidiaryCic)
                try await employee.update(on: transaction)
                return ("Updated")
            } else {
                //Create
                guard let subsidiaryId = try await Subsidiary.findSubsidiary(subsidiaryCic: payload.subsidiaryCic, on: transaction)?.id else {
                    throw Abort(.badRequest, reason: "La subsidiaria no existe")
                }
                guard try await !employeeUserNameExist(employeeDTO: employeeDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre de usuario ya existe")
                }
                guard try await !employeeFullNameExist(employeeDTO: employeeDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre y apellido del empleado ya existe")
                }
                let employeeNew = Employee(
                    employeeCic: UUID().uuidString,
                    user: employeeDTO.user,
                    name: employeeDTO.name,
                    lastName: employeeDTO.lastName,
                    email: employeeDTO.email,
                    phoneNumber: employeeDTO.phoneNumber,
                    role: employeeDTO.role,
                    active: employeeDTO.active,
                    imageUrl: employeeDTO.imageUrl,
                    syncToken: await syncManager.nextBranchToken(subsidiaryCic: payload.subsidiaryCic),
                    subsidiaryID: subsidiaryId
                )
                try await employeeNew.save(on: transaction)
                return ("Created")
            }
        }
        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return DefaultResponse(message: responseString)
    }
    private func employeeUserNameExist(employeeDTO: EmployeeServerDTO, db: any Database) async throws -> Bool {
        let userName = employeeDTO.user
        let query = try await Employee.query(on: db)
            .filter(\.$user == userName)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
    private func employeeFullNameExist(employeeDTO: EmployeeServerDTO, db: any Database) async throws -> Bool {
        let name = employeeDTO.name
        let lastName = employeeDTO.lastName
        let query = try await Employee.query(on: db)
            .filter(\.$name == name)
            .filter(\.$lastName == lastName)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
}
