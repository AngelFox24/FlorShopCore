import Vapor

actor SyncManager {
    let webSocketManager: WebSocketClientManager
    let syncTimesStampManager: SyncTimestamp
    init(
        webSocketManager: WebSocketClientManager,
        syncTimesStampManager: SyncTimestamp
    ) {
        self.webSocketManager = webSocketManager
        self.syncTimesStampManager = syncTimesStampManager
    }
    //MARK: WebSocket
    func addClient(ws: WebSocket) async throws {
        try await webSocketManager.addClient(ws: ws)
        try await webSocketManager.sendUpdateToClient(ws: ws, syncParameters: syncTimesStampManager.getLastSyncDate())
        print("✅ Cliente agregado")
    }
    func removeClient(ws: WebSocket) async {
        await webSocketManager.removeClient(ws: ws)
        print("❌ Cliente removido")
    }
    //MARK: SyncTimesStamp
    func updateLastSyncDate(to syncEntities: [SyncEntities]) async {
        await syncTimesStampManager.updateLastSyncDate(to: syncEntities)
        await sendSyncData()
    }
    func getLastSyncDate() async -> VerifySyncParameters {
        await syncTimesStampManager.getLastSyncDate()
    }
    func getUpdatedSyncTokens(entity: SyncEntities, clientTokens: VerifySyncParameters) async -> VerifySyncParameters {
        await syncTimesStampManager.getUpdatedSyncTokens(entity: entity, clientTokens: clientTokens)
    }
    func shouldSync(clientSyncIds: VerifySyncParameters, entity: SyncEntities) async throws -> Bool {
        try await syncTimesStampManager.shouldSync(clientSyncIds: clientSyncIds, entity: entity)
    }
    private func sendSyncData() async {
        let syncData = await syncTimesStampManager.getLastSyncDate()
        await webSocketManager.broadcast(syncData)
    }
}
