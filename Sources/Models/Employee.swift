import Fluent
import Foundation
import FlorShopDTOs

final class Employee: Model, @unchecked Sendable {
    static let schema = "employees"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "employee_cic") var employeeCic: String
    @Field(key: "name") var name: String
    @Field(key: "lastName") var lastName: String?
    @Field(key: "email") var email: String
    @Field(key: "phoneNumber") var phoneNumber: String?
    @Field(key: "imageUrl") var imageUrl: String?
    @Field(key: "syncToken") var syncToken: Int64
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "company_id") var company: Company
    @Children(for: \.$employee) var toSale: [Sale]
    @Children(for: \.$employee) var toEmployeeSubsidiary: [EmployeeSubsidiary]
    
    init() { }
    
    init(
        employeeCic: String,
        name: String,
        lastName: String?,
        email: String,
        phoneNumber: String?,
        imageUrl: String?,
        syncToken: Int64,
        companyID: Company.IDValue
    ) {
        self.employeeCic = employeeCic
        self.name = name
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.imageUrl = imageUrl
        self.syncToken = syncToken
        self.$company.id = companyID
    }
}

extension Employee {
    static func findEmployee(employeeCic: String, subsidiaryCic: String, on db: any Database) async throws -> Employee? {
        return try await Employee.query(on: db)
            .join(Subsidiary.self, on: \Subsidiary.$id == \Employee.$id)
            .filter(Subsidiary.self, \.$subsidiaryCic == subsidiaryCic)
            .filter(Employee.self, \.$employeeCic == employeeCic)
            .first()
    }
}
