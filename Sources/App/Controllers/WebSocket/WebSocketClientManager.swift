import Fluent
import Vapor
import NIOConcurrencyHelpers  // necesario para NIOLock

actor WebSocketClientManager {
    private var clients: [WebSocket] = []

    func addClient(ws: WebSocket) async throws {
        clients.append(ws)
    }

    func removeClient(ws: WebSocket) {
        clients.removeAll { $0 === ws }
    }
    
    func sendUpdateToClient(ws: WebSocket, syncParameters: VerifySyncParameters) async throws {
        if let data = encodeSyncParameters(syncParameters) {
            try await ws.send(data)
        }
    }

    func broadcast(_ parameters: VerifySyncParameters) {
        guard let syncParameters = encodeSyncParameters(parameters) else { return }

        for ws in clients {
            ws.send(syncParameters)
        }
    }

    private func encodeSyncParameters(_ parameters: VerifySyncParameters) -> String? {
        guard let data = try? JSONEncoder().encode(parameters) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
