import Fluent

struct CreateSaleDetail: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(SaleDetail.schema)
            .id()
            .field("product_name", .string, .required)
            .field("bar_code", .string, .required)
            .field("quantity_sold", .int, .required)
            .field("subtotal", .int, .required)
            .field("unit_type", .string, .required)
            .field("unit_cost", .int, .required)
            .field("unit_price", .int, .required)
            .field("image_url", .string)
            .field("subsidiary_cic", .string, .required)
            .field("sale_id", .uuid, .required, .references(Sale.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(SaleDetail.schema).delete()
    }
}
