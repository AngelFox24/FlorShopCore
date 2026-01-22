import Fluent

struct CreateProduct: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Product.schema)
            .id()
            .field("product_cic", .string, .required)
            .field("bar_code", .string, .required)
            .field("product_name", .string, .required)
            .field("unit_type", .string, .required)
            .field("image_url", .string)
            .field("company_cic", .string, .required)
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
