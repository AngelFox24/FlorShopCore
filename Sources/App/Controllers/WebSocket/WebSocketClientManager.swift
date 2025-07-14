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
    
    func sendUpdateToClient(ws: WebSocket, syncToken: Int64) {
        if let data = encodeSyncParameters(syncToken) {
            ws.send(data)
        }
    }

    func broadcast(_ syncToken: Int64) {
        guard let syncParameters = encodeSyncParameters(syncToken) else { return }

        for ws in clients {
            ws.send(syncParameters)
        }
    }

    private func encodeSyncParameters(_ parameters: Int64) -> String? {
        guard let data = try? JSONEncoder().encode(parameters) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
