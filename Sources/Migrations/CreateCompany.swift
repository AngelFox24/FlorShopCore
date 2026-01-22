import Fluent

struct CreateCompany: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Company.schema)
            .id()
            .field("company_cic", .string, .required)
            .field("company_name", .string, .required)
            .field("ruc", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "company_cic")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Company.schema).delete()
    }
}


