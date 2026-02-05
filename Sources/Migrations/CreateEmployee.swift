import Fluent

struct CreateEmployee: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Employee.schema)
            .id()
            .field("employee_cic", .string, .required)
            .field("name", .string, .required)
            .field("last_name", .string)
            .field("email", .string, .required)
            .field("phone_number", .string)
            .field("image_url", .string)
            .field("company_cic", .string, .required)
            .field("company_id", .uuid, .required, .references(Company.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "employee_cic", "company_cic")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Employee.schema).delete()
    }
}
