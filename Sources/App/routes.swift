import Fluent
import Vapor

func routes(_ app: Application) throws {
    let webSocket = WebSocketClientManager()
    let syncTimesStam = SyncTimestamp()
    let syncManager = SyncManager(webSocketManager: webSocket, syncTimesStampManager: syncTimesStam)
    try app.register(collection: VerifySyncController(syncManager: syncManager))
    try app.register(collection: SessionController(syncManager: syncManager))
    try app.register(collection: CompanyController(syncManager: syncManager))
    try app.register(collection: ImageUrlController(syncManager: syncManager))
    try app.register(collection: SubsidiaryController(syncManager: syncManager))
    try app.register(collection: ProductController(syncManager: syncManager))
    try app.register(collection: CustomerContoller(syncManager: syncManager))
    try app.register(collection: EmployeeController(syncManager: syncManager))
    try app.register(collection: SaleController(syncManager: syncManager))
}
