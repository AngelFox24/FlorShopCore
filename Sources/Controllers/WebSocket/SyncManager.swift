import Vapor
import FlorShopDTOs

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
    func addClient(ws: WebSocket, subsidiaryCic: String, employeeCic: String) async throws {
        try await webSocketManager.addClient(ws: ws, subsidiaryCic: subsidiaryCic, employeeCic: employeeCic)
        
        // Envía ambos tokens al conectar el cliente
        let globalToken = await self.globalManager.tokenValue()
        let branchToken = await self.branchManager.tokenValue(subsidiaryCic: subsidiaryCic)
        let tokens = SyncTokensDTO(
            globalToken: globalToken,
            branchToken: branchToken
        )
        await webSocketManager.sendUpdateToClient(ws: ws, syncToken: tokens)
        
        print("[SyncManager] ✅ Cliente agregado con tokens global y por sucursal con employeeCic: \(employeeCic)")
    }
    
    func removeClient(ws: WebSocket) async {
        await webSocketManager.removeClient(ws: ws)
        print("[SyncManager] ❌ Cliente removido")
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
        print("[SyncManager] Enviando sincronizacion")
        let globalToken = await self.globalManager.tokenValue()
        let branchToken = await self.branchManager.tokenValue(subsidiaryCic: subsidiaryCic)
        if globalToken != oldGlobalToken {
            let tokens = SyncTokensDTO(
                globalToken: globalToken,
                branchToken: nil
            )
            print("[SyncManager] Enviando global broadcast token: \(globalToken)")
            await webSocketManager.globalBroadcast(tokens)
        }
        if branchToken != oldBranchToken {
            let tokens = SyncTokensDTO(
                globalToken: nil,
                branchToken: branchToken
            )
            print("[SyncManager] Enviando branch broadcast token: \(branchToken)")
            await webSocketManager.branchBroadcast(subsidiaryCic: subsidiaryCic, syncToken: tokens)
        }
    }
}
