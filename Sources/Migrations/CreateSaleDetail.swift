import Fluent

struct CreateSaleDetail: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(SaleDetail.schema)
            .id()
            .field("productName", .string, .required)
            .field("barCode", .string, .required)
            .field("quantitySold", .int, .required)
            .field("subtotal", .int, .required)
            .field("unitType", .string, .required)
            .field("unitCost", .int, .required)
            .field("unitPrice", .int, .required)
            .field("imageUrl", .string)
            .field("syncToken", .int64, .required, .sql(.default(0)))
            .field("sale_id", .uuid, .required, .references(Sale.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(SaleDetail.schema).delete()
    }
}
