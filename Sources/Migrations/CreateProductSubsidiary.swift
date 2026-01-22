import Fluent

struct CreateProductSubsidiary: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(ProductSubsidiary.schema)
            .id()
            .field("active", .bool, .required)
            .field("expiration_date", .date)
            .field("quantity_stock", .int, .required)
            .field("unit_cost", .int, .required)
            .field("unit_price", .int, .required)
            .field("subsidiary_cic", .string, .required)
            .field("product_id", .uuid, .required, .references(Product.schema, "id"))
            .field("subsidiary_id", .uuid, .required, .references(Subsidiary.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "product_id", "subsidiary_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(ProductSubsidiary.schema).delete()
    }
}
