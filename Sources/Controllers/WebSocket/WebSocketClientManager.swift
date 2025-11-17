import Fluent
import Vapor
import NIOConcurrencyHelpers  // necesario para NIOLock

actor WebSocketClientManager {
    private struct Client {
        let ws: WebSocket
        let subsidiaryCic: String
    }
    private var clients: [Client] = []

    func addClient(ws: WebSocket, subsidiaryCic: String) async throws {
        clients.removeAll { $0.subsidiaryCic == subsidiaryCic }
        clients.append(.init(ws: ws, subsidiaryCic: subsidiaryCic))
    }

    func removeClient(ws: WebSocket, subsidiaryCic: String? = nil) {
        clients.removeAll { $0.ws === ws }
        if let subsidiaryCic {
            clients.removeAll { $0.subsidiaryCic == subsidiaryCic }
        }
    }
    
    func sendUpdateToClient(ws: WebSocket, syncToken: SyncTokensDTO) {
        if let encoded = encodeSyncTokens(syncToken) {
            ws.send(encoded)
        }
    }

    func globalBroadcast(_ syncToken: SyncTokensDTO) {
        guard let encoded = encodeSyncTokens(syncToken) else { return }
        for client in clients {
            client.ws.send(encoded)
        }
    }
    
    func branchBroadcast(subsidiaryCic: String, syncToken: SyncTokensDTO) {
        guard let encoded = encodeSyncTokens(syncToken) else { return }
        if let client = clients.first(where: { $0.subsidiaryCic == subsidiaryCic }) {
            client.ws.send(encoded)
        }
    }

    private func encodeSyncTokens(_ parameters: SyncTokensDTO) -> String? {
        guard let data = try? JSONEncoder().encode(parameters) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

struct SyncTokensDTO: Codable {
    let globalToken: Int64?
    let branchToken: Int64?
    init(globalToken: Int64?, branchToken: Int64?) {
        self.globalToken = globalToken
        self.branchToken = branchToken
    }
}
