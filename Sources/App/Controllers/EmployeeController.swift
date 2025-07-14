import Fluent
import Vapor

struct EmployeeController: RouteCollection {
    let syncManager: SyncManager
    let imageUrlService: ImageUrlService
    func boot(routes: any RoutesBuilder) throws {
        let employees = routes.grouped("employees")
        employees.post(use: self.save)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        let employeeDTO = try req.content.decode(EmployeeInputDTO.self)
        let responseString: String = try await req.db.transaction { transaction -> String in
            let imageId = try await imageUrlService.save(
                db: transaction,
                imageUrlInputDto: employeeDTO.imageUrl,
                syncToken: syncManager.nextToken()
            )
            if let employee = try await Employee.find(employeeDTO.id, on: transaction) {
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
                employee.syncToken = await syncManager.nextToken()
                employee.$imageUrl.id = imageId
                try await employee.update(on: transaction)
                return ("Updated")
            } else {
                //Create
                guard let subsidiaryId = try await Subsidiary.find(employeeDTO.subsidiaryID, on: transaction)?.id else {
                    throw Abort(.badRequest, reason: "La subsidiaria no existe")
                }
                guard try await !employeeUserNameExist(employeeDTO: employeeDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre de usuario ya existe")
                }
                guard try await !employeeFullNameExist(employeeDTO: employeeDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre y apellido del empleado ya existe")
                }
                let employeeNew = Employee(
                    id: UUID(),
                    user: employeeDTO.user,
                    name: employeeDTO.name,
                    lastName: employeeDTO.lastName,
                    email: employeeDTO.email,
                    phoneNumber: employeeDTO.phoneNumber,
                    role: employeeDTO.role,
                    active: employeeDTO.active,
                    syncToken: await syncManager.nextToken(),
                    subsidiaryID: subsidiaryId,
                    imageUrlID: imageId
                )
                try await employeeNew.save(on: transaction)
                return ("Created")
            }
        }
        await self.syncManager.sendSyncData()
        return DefaultResponse(message: responseString)
    }
    private func employeeUserNameExist(employeeDTO: EmployeeInputDTO, db: any Database) async throws -> Bool {
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
    private func employeeFullNameExist(employeeDTO: EmployeeInputDTO, db: any Database) async throws -> Bool {
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
