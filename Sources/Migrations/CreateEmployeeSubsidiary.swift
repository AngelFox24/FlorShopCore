import Fluent

struct CreateEmployeeSubsidiary: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(EmployeeSubsidiary.schema)
            .id()
            .field("role", .string, .required)
            .field("active", .bool, .required)
//            .field("syncToken", .int64, .required, .sql(.default(0)))
            .field("subsidiary_id", .uuid, .required, .references(Subsidiary.schema, "id"))
            .field("employee_id", .uuid, .required, .references(Employee.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "subsidiary_id", "employee_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(EmployeeSubsidiary.schema).delete()
    }
}
