import Fluent
import Vapor

func routes(_ app: Application) async throws {
    let webSocket = WebSocketClientManager()
    let syncTokenManager = try await SyncTokenManager.makeSyncTokenManager(db: app.db)
    let syncManager = SyncManager(webSocketManager: webSocket, syncTokenManager: syncTokenManager)
    let imageService = ImageUrlService()
    try app.register(collection: SyncController(syncManager: syncManager))
    try app.register(collection: SessionController(syncManager: syncManager, imageUrlService: imageService))
    try app.register(collection: CompanyController(syncManager: syncManager))
    try app.register(collection: ImageUrlController(syncManager: syncManager, imageUrlService: imageService))
    try app.register(collection: SubsidiaryController(syncManager: syncManager, imageUrlService: imageService))
    try app.register(collection: ProductController(syncManager: syncManager, imageUrlService: imageService))
    try app.register(collection: CustomerContoller(syncManager: syncManager, imageUrlService: imageService))
    try app.register(collection: EmployeeController(syncManager: syncManager, imageUrlService: imageService))
    try app.register(collection: SaleController(syncManager: syncManager))
}
