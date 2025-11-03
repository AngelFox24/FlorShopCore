import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) async throws {
    app.http.server.configuration.hostname = app.getHostname()
    app.http.server.configuration.port = app.getPort()
    app.routes.defaultMaxBodySize = "10mb"
    try app.configLogger()
    app.databases.use(try app.getFactory(), as: app.getDatabaseID())
    app.migrations.add(CreateCompany())
    app.migrations.add(CreateImageUrl())
    app.migrations.add(CreateSubsidiary())
    app.migrations.add(CreateCustomer())
    app.migrations.add(CreateProduct())
    app.migrations.add(CreateEmployee())
    app.migrations.add(CreateSale())
    app.migrations.add(CreateSaleDetail())
    //Espera a que la migracion se haga
    try await app.autoMigrate()
    //No espera a que la migracion se haga
//    try app.autoMigrate().get()
    // register routes
    try await routes(app)
}
