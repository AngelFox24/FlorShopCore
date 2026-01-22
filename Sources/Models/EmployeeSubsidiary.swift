import Fluent
import Foundation
import FlorShopDTOs

final class EmployeeSubsidiary: Model, @unchecked Sendable {
    static let schema = "employees_subsidiaries"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "role") var role: UserSubsidiaryRole
    @Field(key: "active") var active: Bool
    @Field(key: "subsidiary_cic") var subsidiaryCic: String
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "subsidiary_id") var subsidiary: Subsidiary
    @Parent(key: "employee_id") var employee: Employee
    @Children(for: \.$employeeSubsidiary) var toSale: [Sale]
    
    init() { }
    
    init(
        role: UserSubsidiaryRole,
        active: Bool,
        subsidiaryCic: String,
        subsidiaryID: Subsidiary.IDValue,
        employeeID: Employee.IDValue
    ) {
        self.role = role
        self.active = active
        self.subsidiaryCic = subsidiaryCic
        self.$subsidiary.id = subsidiaryID
        self.$employee.id = employeeID
    }
}

extension EmployeeSubsidiary {
    static func findEmployeeSubsidiary(employeeCic: String, subsisiaryCic: String, on db: any Database) async throws -> EmployeeSubsidiary? {
        try await EmployeeSubsidiary.query(on: db)
            .join(Subsidiary.self, on: \Subsidiary.$id == \EmployeeSubsidiary.$subsidiary.$id)
            .join(Employee.self, on: \Employee.$id == \EmployeeSubsidiary.$employee.$id)
            .filter(Subsidiary.self, \.$subsidiaryCic == subsisiaryCic)
            .filter(Employee.self, \.$employeeCic == employeeCic)
            .with(\.$employee)
            .first()
    }
}
