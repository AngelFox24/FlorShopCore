import Fluent

struct CreateSale: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Sale.schema)
            .id()
            .field("paymentType", .string, .required)
            .field("saleDate", .date, .required)
            .field("total", .int, .required)
            .field("syncToken", .int64, .required, .sql(.default(0)))
            .field("subsidiary_id", .uuid, .required, .references(Subsidiary.schema, "id"))
            .field("employee_id", .uuid, .required, .references(Employee.schema, "id"))
            .field("customer_id", .uuid, .references(Customer.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Sale.schema).delete()
    }
}
