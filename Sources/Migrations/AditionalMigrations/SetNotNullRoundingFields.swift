import Fluent
import FluentPostgresDriver

struct SetNotNullRoundingFields: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? (any SQLDatabase) else {
            return
        }
        // 1️⃣ Agregar columnas como opcionales
        try await database.schema(Sale.schema)
            .field("total_charged", .int)
            .field("rounding_difference", .int)
            .update()
        // 2️⃣ Backfill de datos existentes
        try await sqlDatabase.raw("""
            UPDATE sales
            SET
                total_charged = total,
                rounding_difference = 0
            WHERE total_charged IS NULL;
        """).run()
        // 3️⃣ Convertirlas en NOT NULL
        try await sqlDatabase.raw("""
                ALTER TABLE sales
                ALTER COLUMN total_charged SET NOT NULL,
                ALTER COLUMN rounding_difference SET NOT NULL;
            """).run()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Sale.schema)
            .deleteField("total_charged")
            .deleteField("rounding_difference")
            .update()
    }
}
