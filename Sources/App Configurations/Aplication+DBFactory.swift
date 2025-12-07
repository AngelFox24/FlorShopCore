import FluentPostgresDriver
import Vapor

extension Application {
    func getFactory() throws -> DatabaseConfigurationFactory {
        guard let hostname = Environment.get(EnvironmentVariables.bataBaseHost.rawValue),
              let port = Environment.get(EnvironmentVariables.bataBasePort.rawValue),
              let username = Environment.get(EnvironmentVariables.bataBaseUserName.rawValue),
              let password = Environment.get(EnvironmentVariables.bataBasePassword.rawValue),
              let database = Environment.get(EnvironmentVariables.bataBaseName.rawValue) else {
            fatalError("Missing database configuration in .env.\(self.environment)")
        }
        guard let portInt = Int(port),
              portInt > 0 else {
            fatalError("\(EnvironmentVariables.bataBasePort.rawValue) must be an integer in .env.\(self.environment)")
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

