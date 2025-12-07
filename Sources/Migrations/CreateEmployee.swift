import Fluent

struct CreateEmployee: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Employee.schema)
            .id()
            .field("employee_cic", .string, .required)
            .field("name", .string, .required)
            .field("lastName", .string)
            .field("email", .string, .required)
            .field("phoneNumber", .string)
            .field("imageUrl", .string)
            .field("syncToken", .int64, .required, .sql(.default(0)))
            .field("company_id", .uuid, .required, .references(Company.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "employee_cic")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Employee.schema).delete()
    }
}
