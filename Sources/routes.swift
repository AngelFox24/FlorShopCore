import Fluent
import Vapor

func routes(_ app: Application) async throws {
//    let webSocket = WebSocketClientManager()
//    let branchTokenManager = try await BranchScopedSyncTokenManager.makeManager(db: app.db)
//    let globalTokenManager = try await GlobalSyncTokenManager.makeSyncTokenManager(db: app.db)
//    let syncManager = SyncManager(webSocketManager: webSocket, branchManager: branchTokenManager, globalManager: globalTokenManager)
    let validator = FlorShopAuthValitator(jwksURL: Environment.get(EnvironmentVariables.authBaseUrl.rawValue)!)
    let florShopAuthProvider = FlorShopAuthProvider()
    try app.register(collection: Test(validator: validator))
//    try app.register(collection: SyncController(syncManager: syncManager, validator: validator))
    try app.register(collection: SessionController(validator: validator))
    try app.register(collection: CompanyController(validator: validator, florShopAuthProvider: florShopAuthProvider))
    try app.register(collection: SubsidiaryController(validator: validator, florShopAuthProvider: florShopAuthProvider))
    try app.register(collection: ProductController(validator: validator))
    try app.register(collection: CustomerContoller(validator: validator))
    try app.register(collection: EmployeeController(validator: validator, florShopAuthProvider: florShopAuthProvider))
    try app.register(collection: SaleController(validator: validator))
}
