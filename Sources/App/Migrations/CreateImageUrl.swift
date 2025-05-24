import Fluent

struct CreateImageUrl: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("imageUrls")
            .id()
            .field("imageUrl", .string, .required)
            .field("imageHash", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("imageUrls").delete()
    }
}
