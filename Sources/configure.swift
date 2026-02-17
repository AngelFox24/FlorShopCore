import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) async throws {
    app.http.server.configuration.hostname = app.getHostname()
    app.http.server.configuration.port = app.getPort()
    app.routes.defaultMaxBodySize = "10mb"
    app.configLogger()
    app.setJsonDecoder()
    await app.setSignature()
    app.databases.use(try app.getFactory(), as: app.getDatabaseID())
    app.configureMigrations()
    try await app.autoMigrate()
    try await routes(app)
}
