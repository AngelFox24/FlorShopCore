import Fluent

struct CreateCustomer: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Customer.schema)
            .id()
            .field("customer_cic", .string, .required)
            .field("name", .string, .required)
            .field("lastName", .string)
            .field("totalDebt", .int, .required)
            .field("creditScore", .int, .required)
            .field("creditDays", .int, .required)
            .field("dateLimit", .date, .required)
            .field("lastDatePurchase", .date, .required)
            .field("firstDatePurchaseWithCredit", .date)
            .field("phoneNumber", .string)
            .field("creditLimit", .int, .required)
            .field("isCreditLimitActive", .bool, .required)
            .field("isCreditLimit", .bool, .required)
            .field("isDateLimitActive", .bool, .required)
            .field("isDateLimit", .bool, .required)
            .field("imageUrl", .string)
            .field("syncToken", .int64, .required, .sql(.default(0)))
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
