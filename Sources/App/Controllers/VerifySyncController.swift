import Fluent
import Vapor

struct VerifySyncController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let subsidiaries = routes.grouped("verifySync")
        subsidiaries.post(use: self.getTokens)
        // Nuevo endpoint WebSocket sin afectar el anterior
        subsidiaries.webSocket("ws", onUpgrade: self.handleWebSocket)
    }
    @Sendable
    func getTokens(req: Request) async throws -> VerifySyncParameters {
        print("Api version 2.0")
        return await SyncTimestamp.shared.getLastSyncDate()
    }
    @Sendable
    func handleWebSocket(req: Request, ws: WebSocket) async {
        print("WebSocket version 2.0")
        try? await WebSocketClientManager.shared.addClient(ws)
    }
}
