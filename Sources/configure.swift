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
    app.migrations.add(CreateCompany())
    app.migrations.add(CreateSubsidiary())
    app.migrations.add(CreateCustomer())
    app.migrations.add(CreateProduct())
    app.migrations.add(CreateProductSubsidiary())
    app.migrations.add(CreateEmployee())
    app.migrations.add(CreateEmployeeSubsidiary())
    app.migrations.add(CreateSale())
    app.migrations.add(CreateSaleDetail())
    try await app.autoMigrate()
    try await routes(app)
}
