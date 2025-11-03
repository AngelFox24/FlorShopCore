import Foundation
import FluentPostgresDriver
import Vapor
import NIOSSL

struct DBConfig {
    static func production() throws -> DatabaseConfigurationFactory {
        .postgres(configuration: .init(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "FlorCloudBDv1",
            tls: .prefer(try .init(configuration: .clientDefault))
        ))
    }
    static func development() -> DatabaseConfigurationFactory {
        .postgres(configuration: .init(
            hostname: "192.168.2.7",
            port: 5432,
            username: "vapor_username",
            password: "vapor_password",
            database: "FlorCloudBDv1",
            tls: .disable
        ))
    }
}
