import Fluent
import Vapor

struct VerifySyncController: RouteCollection {
    let syncManager: SyncManager
    func boot(routes: any RoutesBuilder) throws {
        let subsidiaries = routes.grouped("verifySync")
        subsidiaries.post(use: self.getTokens)
        // Nuevo endpoint WebSocket sin afectar el anterior
        subsidiaries.webSocket("ws", onUpgrade: self.handleWebSocket)
    }
    @Sendable
    func getTokens(req: Request) async throws -> VerifySyncParameters {
        print("Api version 2.0")
        return await syncManager.getLastSyncDate()
    }
    @Sendable
    func handleWebSocket(req: Request, ws: WebSocket) async {
        print("WebSocket version 2.0")
        // Establece un intervalo de ping
        ws.pingInterval = .seconds(10)
        try? await syncManager.addClient(ws: ws)
        
        ws.onClose.whenComplete { _ in
            Task {
                await syncManager.removeClient(ws: ws)
            }
        }
    }
}
