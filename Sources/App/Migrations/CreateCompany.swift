import Fluent

struct CreateCompany: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("companies")
            .id()
            .field("companyName", .string, .required)
            .field("ruc", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("companies").delete()
    }
}


