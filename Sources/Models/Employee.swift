import Fluent
import Foundation
import FlorShopDTOs

final class Employee: Model, @unchecked Sendable {
    static let schema = "employees"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "employee_cic") var employeeCic: String
    @Field(key: "user") var user: String
    @Field(key: "name") var name: String
    @Field(key: "lastName") var lastName: String
    @Field(key: "email") var email: String
    @Field(key: "phoneNumber") var phoneNumber: String
    @Field(key: "role") var role: UserSubsidiaryRole
    @Field(key: "active") var active: Bool
    @Field(key: "imageUrl") var imageUrl: String?
    @Field(key: "syncToken") var syncToken: Int64
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "subsidiary_id") var subsidiary: Subsidiary
    @Children(for: \.$employee) var toSale: [Sale]
    
    init() { }
    
    init(
        employeeCic: String,
        user: String,
        name: String,
        lastName: String,
        email: String,
        phoneNumber: String,
        role: UserSubsidiaryRole,
        active: Bool,
        imageUrl: String?,
        syncToken: Int64,
        subsidiaryID: Subsidiary.IDValue
    ) {
        self.employeeCic = employeeCic
        self.user = user
        self.name = name
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.role = role
        self.active = active
        self.imageUrl = imageUrl
        self.syncToken = syncToken
        self.$subsidiary.id = subsidiaryID
    }
}

extension Employee {
    static func findEmployee(employeeCic: String?, on db: any Database) async throws -> Employee? {
        guard let employeeCic else { return nil }
        return try await Employee.query(on: db)
            .filter(Employee.self, \.$employeeCic == employeeCic)
            .first()
    }
}
