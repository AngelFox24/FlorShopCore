import Fluent

struct CreateCustomer: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Customer.schema)
            .id()
            .field("customer_cic", .string, .required)
            .field("name", .string, .required)
            .field("last_name", .string)
            .field("total_debt", .int, .required)
            .field("credit_score", .int, .required)
            .field("credit_days", .int, .required)
            .field("date_limit", .date, .required)
            .field("last_date_purchase", .date, .required)
            .field("first_date_purchase_with_credit", .date)
            .field("phone_number", .string)
            .field("credit_limit", .int, .required)
            .field("is_credit_limit_active", .bool, .required)
            .field("is_credit_limit", .bool, .required)
            .field("is_date_limit_active", .bool, .required)
            .field("is_date_limit", .bool, .required)
            .field("image_url", .string)
            .field("company_cic", .string, .required)
            .field("company_id", .uuid, .required, .references(Company.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "customer_cic")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Customer.schema).delete()
    }
}
