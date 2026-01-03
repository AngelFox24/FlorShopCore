import Fluent
import FlorShopDTOs
import Vapor

struct EmployeeController: RouteCollection {
    let syncManager: SyncManager
    let validator: FlorShopAuthValitator
    let florShopAuthProvider: FlorShopAuthProvider
    func boot(routes: any RoutesBuilder) throws {
        let employees = routes.grouped("employees")
        employees.post(use: self.save)
        let isComplete = employees.grouped("isComplete")
        isComplete.get(use: self.isProfileComplete)
    }
    //GET: /employees/isComplete
    @Sendable
    func isProfileComplete(req: Request) async throws -> CompleteRegistrationResponse {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        let isRegistered: Bool
        let message: String
        if let _ = try await EmployeeSubsidiary.findEmployeeSubsidiary(employeeCic: payload.sub.value, subsisiaryCic: payload.subsidiaryCic, on: req.db) {
            isRegistered = true
            message = "Employee is already registered"
        } else {
            isRegistered = false
            message = "Employee is not registered"
        }
        return CompleteRegistrationResponse(
            isRegistered: isRegistered,
            message: message
        )
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
            guard let subsidiaryEntity = try await Subsidiary.findSubsidiary(subsidiaryCic: payload.subsidiaryCic, on: transaction),
                  let subsidiaryId = subsidiaryEntity.id else {
                throw Abort(.badRequest, reason: "La subsidiaria no existe")
            }
            if let employeeCic = employeeDTO.employeeCic {//Tiene la intension de actualizar empleado
                //Update
                var result = "Don't updated"
                guard let employee = try await Employee.findEmployee(employeeCic: employeeCic, subsidiaryCic: payload.subsidiaryCic, on: transaction) else {
                    throw Abort(.badRequest, reason: "El producto no existe para ser actualizado")
                }
                if !employeeDTO.isMainEqual(to: employee) {
                    if employee.name != employeeDTO.name || employee.lastName != employeeDTO.lastName {
                        guard try await !employeeFullNameExist(employeeDTO: employeeDTO, db: transaction) else {
                            throw Abort(.badRequest, reason: "El nombre y apellido del empleado ya existe")
                        }
                        employee.name = employeeDTO.name
                        employee.lastName = employeeDTO.lastName
                    }
                    employee.email = employeeDTO.email
                    employee.phoneNumber = employeeDTO.phoneNumber
                    employee.imageUrl = employeeDTO.imageUrl
                    employee.syncToken = await syncManager.nextGlobalToken()
                    try await employee.update(on: transaction)
                    result = "Updated"
                }
                guard let employeeSubsidiary = try await EmployeeSubsidiary.findEmployeeSubsidiary(
                    employeeCic: employee.employeeCic,
                    subsisiaryCic: payload.subsidiaryCic,
                    on: transaction
                ) else {
                    throw Abort(.badRequest, reason: "EmployeeSubsidiary no existe")
                }
                if !employeeDTO.isChildEqual(to: employeeSubsidiary) {
                    //TODO: Segregate this in a function
                    let internalToken = try await TokenService.generateInternalToken(scopedToken: payload, req: req)
                    let request = UpdateUserSubsidiaryRequest(employeeCic: employee.employeeCic, role: employeeDTO.role, status: employeeDTO.active ? .active : .inactive)
                    try await self.florShopAuthProvider.updateUserSubsidiary(request: request, internalToken: internalToken)
                    employeeSubsidiary.role = employeeDTO.role
                    employeeSubsidiary.active = employeeDTO.active
                    employeeSubsidiary.syncToken = await syncManager.nextBranchToken(subsidiaryCic: subsidiaryEntity.subsidiaryCic)
                    try await employeeSubsidiary.update(on: transaction)
                    result = "Updated"
                }
                return result
            } else {///Las creacion de empleado no son creadas por terceros, es mas completar registro, solo un empleados que en su token tienen el cic con ese se crea
                //Create
                //TODO: Validar que el email debe ser solo del employee segun FlorShopAuth
                //TODO: Si manda nulo el employeeCic y ya existe ese employeeCic entonces hay que permitir que lo actualize
                guard let companyId = try await Company.findCompany(companyCic: payload.companyCic, on: transaction)?.id else {
                    throw Abort(.badRequest, reason: "La compañia no existe")
                }
                guard try await !employeeFullNameExist(employeeDTO: employeeDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre y apellido del empleado ya existe")
                }
                let employeeNew = Employee(
                    employeeCic: payload.sub.value,
                    name: employeeDTO.name,
                    lastName: employeeDTO.lastName,
                    email: employeeDTO.email,
                    phoneNumber: employeeDTO.phoneNumber,
                    imageUrl: employeeDTO.imageUrl,
                    syncToken: await syncManager.nextGlobalToken(),
                    companyID: companyId
                )
                try await employeeNew.save(on: transaction)
                guard let employeeId = employeeNew.id else {
                    throw Abort(.internalServerError, reason: "Employee id no encontrado")
                }
                let newEmployeeSubsidiary = EmployeeSubsidiary(
                    //TODO: Consultar con FlorShopAuth si los roles estan de acuerdo a su scoped token
                    role: employeeDTO.role,
                    active: employeeDTO.active,
                    syncToken: await syncManager.nextBranchToken(subsidiaryCic: subsidiaryEntity.subsidiaryCic),
                    subsidiaryID: subsidiaryId,
                    employeeID: employeeId
                )
                try await newEmployeeSubsidiary.save(on: transaction)
                return ("Created")
            }
        }
        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return DefaultResponse(message: responseString)
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
