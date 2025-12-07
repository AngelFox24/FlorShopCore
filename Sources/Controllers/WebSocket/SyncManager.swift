import Vapor

actor SyncManager {
    private let webSocketManager: WebSocketClientManager
    private let branchManager: BranchScopedSyncTokenManager
    private let globalManager: GlobalSyncTokenManager
    
    init(
        webSocketManager: WebSocketClientManager,
        branchManager: BranchScopedSyncTokenManager,
        globalManager: GlobalSyncTokenManager
    ) {
        self.webSocketManager = webSocketManager
        self.branchManager = branchManager
        self.globalManager = globalManager
    }
    
    // MARK: - WebSocket
    func addClient(ws: WebSocket, subsidiaryCic: String) async throws {
        try await webSocketManager.addClient(ws: ws, subsidiaryCic: subsidiaryCic)
        
        // Envía ambos tokens al conectar el cliente
        let globalToken = await self.globalManager.tokenValue()
        let branchToken = await self.branchManager.tokenValue(subsidiaryCic: subsidiaryCic)
        let tokens = SyncTokensDTO(
            globalToken: globalToken,
            branchToken: branchToken
        )
        await webSocketManager.sendUpdateToClient(ws: ws, syncToken: tokens)
        
        print("✅ Cliente agregado con tokens global y por sucursal")
    }
    
    func removeClient(ws: WebSocket) async {
        await webSocketManager.removeClient(ws: ws)
        print("❌ Cliente removido")
    }
    
    // MARK: - Tokens globales
    func getLastGlobalToken() async -> Int64 {
        await globalManager.tokenValue()
    }
    
    func nextGlobalToken() async -> Int64 {
        await globalManager.nextToken()
    }
    
    // MARK: - Tokens por sucursal
    func getLastBranchToken(subsidiaryCic: String) async -> Int64 {
        await branchManager.tokenValue(subsidiaryCic: subsidiaryCic)
    }
    
    func nextBranchToken(subsidiaryCic: String) async -> Int64 {
        await branchManager.nextToken(subsidiaryCic: subsidiaryCic)
    }
    
    // MARK: - Difusión
    func sendSyncData(oldGlobalToken: Int64, oldBranchToken: Int64, subsidiaryCic: String) async {
        let globalToken = await self.globalManager.tokenValue()
        let branchToken = await self.branchManager.tokenValue(subsidiaryCic: subsidiaryCic)
        if globalToken != oldGlobalToken {
            let tokens = SyncTokensDTO(
                globalToken: globalToken,
                branchToken: nil
            )
            await webSocketManager.globalBroadcast(tokens)
        }
        if branchToken != oldBranchToken {
            let tokens = SyncTokensDTO(
                globalToken: nil,
                branchToken: branchToken
            )
            await webSocketManager.branchBroadcast(subsidiaryCic: subsidiaryCic, syncToken: tokens)
        }
    }
}
