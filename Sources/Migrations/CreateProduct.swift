import Fluent

struct CreateProduct: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Product.schema)
            .id()
            .field("product_cic", .string, .required)
            .field("barCode", .string, .required)
            .field("productName", .string, .required)
            .field("unitType", .string, .required)
            .field("imageUrl", .string)
            .field("syncToken", .int64, .required, .sql(.default(0)))
            .field("company_id", .uuid, .required, .references(Company.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "product_cic")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Product.schema).delete()
    }
}
