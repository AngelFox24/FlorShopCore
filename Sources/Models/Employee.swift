import Fluent
import Foundation
import FlorShopDTOs

final class Employee: Model, @unchecked Sendable {
    static let schema = "employees"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "employee_cic") var employeeCic: String
    @Field(key: "name") var name: String
    @Field(key: "last_name") var lastName: String?
    @Field(key: "email") var email: String
    @Field(key: "phone_number") var phoneNumber: String?
    @Field(key: "image_url") var imageUrl: String?
    @Field(key: "company_cic") var companyCic: String
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "company_id") var company: Company
    @Children(for: \.$employee) var toEmployeeSubsidiary: [EmployeeSubsidiary]
    
    init() { }
    
    init(
        employeeCic: String,
        name: String,
        lastName: String?,
        email: String,
        phoneNumber: String?,
        imageUrl: String?,
        companyCic: String,
        companyID: Company.IDValue
    ) {
        self.employeeCic = employeeCic
        self.name = name
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.imageUrl = imageUrl
        self.companyCic = companyCic
        self.$company.id = companyID
    }
}

extension Employee {
    static func findEmployee(employeeCic: String, subsidiaryCic: String, on db: any Database) async throws -> Employee? {
        return try await Employee.query(on: db)
            .join(EmployeeSubsidiary.self, on: \EmployeeSubsidiary.$employee.$id == \Employee.$id)
            .join(Subsidiary.self, on: \Subsidiary.$id == \EmployeeSubsidiary.$subsidiary.$id)
            .filter(Subsidiary.self, \.$subsidiaryCic == subsidiaryCic)
            .filter(Employee.self, \.$employeeCic == employeeCic)
            .first()
    }
}
