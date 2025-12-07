import Vapor

enum EnvironmentVariables: String {
    case logLevel = "LOG_LEVEL"
    case httpServerHost = "HTTP_SERVER_HOST"
    case httpServerPort = "HTTP_SERVER_PORT"
    case bataBaseHost = "DATABASE_HOST"
    case bataBaseName = "DATABASE_NAME"
    case bataBasePort = "DATABASE_PORT"
    case bataBaseUserName = "DATABASE_USERNAME"
    case bataBasePassword = "DATABASE_PASSWORD"
    case pgData = "PGDATA"
    case postgresUser = "POSTGRES_USER"
    case postgresPassword = "POSTGRES_PASSWORD"
    case postgresDB = "POSTGRES_DB"
    case jwtHmacInternalKey = "JWT_HMAC_INTERNAL_KEY"
    case authBaseUrl = "AUTH_BASE_URL"
}

extension EnvironmentVariables: CaseIterable {
    static func validate(envName: String) throws {
        let allCases = Self.allCases
        for envVar in allCases {
            guard let _ = Environment.get(envVar.rawValue) else {
                throw Abort(.internalServerError, reason: "\(envVar.rawValue) don't found in .env.\(envName)")
            }
        }
    }
}
