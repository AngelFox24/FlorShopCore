import Fluent
import Vapor

func routes(_ app: Application) throws {
    let webSocket = WebSocketClientManager()
    try app.register(collection: VerifySyncController(webSocketManager: webSocket))
    try app.register(collection: SessionController(webSocketManager: webSocket))
    try app.register(collection: CompanyController(webSocketManager: webSocket))
    try app.register(collection: ImageUrlController(webSocketManager: webSocket))
    try app.register(collection: SubsidiaryController(webSocketManager: webSocket))
    try app.register(collection: ProductController(webSocketManager: webSocket))
    try app.register(collection: CustomerContoller(webSocketManager: webSocket))
    try app.register(collection: EmployeeController(webSocketManager: webSocket))
    try app.register(collection: SaleController(webSocketManager: webSocket))
}
