import Fluent

struct CreateEmployee: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Employee.schema)
            .id()
            .field("employee_cic", .string, .required)
            .field("user", .string, .required)
            .field("name", .string, .required)
            .field("lastName", .string, .required)
            .field("email", .string, .required)
            .field("phoneNumber", .string, .required)
            .field("role", .string, .required)
            .field("active", .bool, .required)
            .field("imageUrl", .string)
            .field("syncToken", .int64, .required, .sql(.default(0)))
            .field("subsidiary_id", .uuid, .required, .references(Subsidiary.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "employee_cic")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Employee.schema).delete()
    }
}
