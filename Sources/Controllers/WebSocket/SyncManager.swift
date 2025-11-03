import Vapor

actor SyncManager {
    private let webSocketManager: WebSocketClientManager
    private let syncTokenManager: SyncTokenManager
    init(
        webSocketManager: WebSocketClientManager,
        syncTokenManager: SyncTokenManager
    ) {
        self.webSocketManager = webSocketManager
        self.syncTokenManager = syncTokenManager
    }
    //MARK: WebSocket
    func addClient(ws: WebSocket) async throws {
        try await webSocketManager.addClient(ws: ws)
        await webSocketManager.sendUpdateToClient(ws: ws, syncToken: syncTokenManager.tokenValue())
        print("✅ Cliente agregado")
    }
    func removeClient(ws: WebSocket) async {
        await webSocketManager.removeClient(ws: ws)
        print("❌ Cliente removido")
    }
    //MARK: Sync Engine
    func getLastSyncToken() async -> Int64 {
        await syncTokenManager.tokenValue()
    }
    func nextToken() async -> Int64 {
        await syncTokenManager.nextToken()
    }
    func sendSyncData() async {
        let syncToken = await syncTokenManager.tokenValue()
        await webSocketManager.broadcast(syncToken)
    }
}
