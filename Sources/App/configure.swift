import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.http.server.configuration.hostname = "localhost" //Server Ubuntu
//    app.http.server.configuration.hostname = "192.168.2.5" //Local Host for Debugging

    app.http.server.configuration.port = 8080
    
    app.routes.defaultMaxBodySize = "10mb"

    //=========== FOR PRODUCCION ===========
    app.databases.use(try DBConfig.production(), as: .psql)
    //=========== FOR PRODUCCION ===========
    //=========== FOR DEBUGGING ===========
//    app.databases.use(DBConfig.development(), as: .psql)
    //=========== FOR DEBUGGING ===========
    
    app.migrations.add(CreateCompany())
    app.migrations.add(CreateImageUrl())
    app.migrations.add(CreateSubsidiary())
    app.migrations.add(CreateCustomer())
    app.migrations.add(CreateProduct())
    app.migrations.add(CreateEmployee())
    app.migrations.add(CreateSale())
    app.migrations.add(CreateSaleDetail())
    //Espera a que la migracion se haga
//    try await app.autoMigrate().wait()
    //No espera a que la migracion se haga
//    try app.autoMigrate().get()
    // register routes
    try routes(app)
}
