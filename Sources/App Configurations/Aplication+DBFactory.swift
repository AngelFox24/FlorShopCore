import FluentPostgresDriver
import Vapor

extension Application {
    func getFactory() throws -> DatabaseConfigurationFactory {
        guard let hostname = Environment.get("DATABASE_HOST"),
              let port = Environment.get("DATABASE_PORT"),
              let username = Environment.get("DATABASE_USERNAME"),
              let password = Environment.get("DATABASE_PASSWORD"),
              let database = Environment.get("DATABASE_NAME") else {
            fatalError("Missing database configuration in .env.\(self.environment)")
        }
        guard let portInt = Int(port),
              portInt > 0 else {
            fatalError("DATABASE_PORT must be an integer in .env.\(self.environment)")
        }
        let tls: PostgresConnection.Configuration.TLS = self.environment == .production
        ? .prefer(try .init(configuration: .clientDefault)) : .disable
        return .postgres(configuration: SQLPostgresConfiguration(
            hostname: hostname,
            port: portInt,
            username: username,
            password: password,
            database: database,
            tls: tls))
    }
    func getDatabaseID() -> DatabaseID {
        switch self.environment {
        default:
            return .psql
        }
    }
}

