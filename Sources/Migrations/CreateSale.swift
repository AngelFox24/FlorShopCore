import Fluent

struct CreateSale: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Sale.schema)
            .id()
            .field("payment_type", .string, .required)
            .field("sale_date", .date, .required)
            .field("total", .int, .required)
            .field("subsidiary_cic", .string, .required)
            .field("subsidiary_id", .uuid, .required, .references(Subsidiary.schema, "id"))
            .field("employee_subsidiary_id", .uuid, .required, .references(EmployeeSubsidiary.schema, "id"))
            .field("customer_id", .uuid, .references(Customer.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Sale.schema).delete()
    }
}
