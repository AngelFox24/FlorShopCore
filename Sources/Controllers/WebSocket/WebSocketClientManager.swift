import Fluent
import Vapor
import FlorShopDTOs
import NIOConcurrencyHelpers  // necesario para NIOLock

actor WebSocketClientManager {
    private struct Client {
        let ws: WebSocket
        let subsidiaryCic: String
        let employeeCic: String
    }
    private var clients: [Client] = []

    func addClient(ws: WebSocket, subsidiaryCic: String, employeeCic: String) async throws {
        try await removeSameClients(subsidiaryCic: subsidiaryCic, employeeCic: employeeCic)
        clients.append(.init(ws: ws, subsidiaryCic: subsidiaryCic, employeeCic: employeeCic))
        var totalClients: String = ""
        for client in self.clients {
            let employeeCic = client.employeeCic
            totalClients += "\(employeeCic)\n"
        }
        print("[WebSocketClientManager] Se agrego un websocket con employeeCic: \(employeeCic), tot: \(self.clients.count), clientes: \n\(totalClients)")
    }
    
    func removeSameClients(subsidiaryCic: String, employeeCic: String) async throws {
        let sameClients = self.clients.filter { $0.subsidiaryCic == subsidiaryCic && $0.employeeCic == employeeCic }
        for client in sameClients {
            print("[WebSocketClientManager] Se corto un websocket con employeeCic: \(client.employeeCic)")
            try await client.ws.close()
        }
        self.clients.removeAll { $0.subsidiaryCic == subsidiaryCic && $0.employeeCic == employeeCic }
    }

    func removeClient(ws: WebSocket, employeeCic: String? = nil) {
        clients.removeAll { $0.ws === ws }
        print("[WebSocketClientManager] Se quito un websocket")
        if let employeeCic {
            clients.removeAll { $0.employeeCic == employeeCic }
            print("[WebSocketClientManager] Se quito un websocket con employeeCic: \(employeeCic)")
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
//            print("[WebSocketClientManager] enviando global token: \(syncToken.globalToken, default: "nil") a employeeCic: \(client.employeeCic)")
            client.ws.send(encoded)
        }
    }
    
    func branchBroadcast(subsidiaryCic: String, syncToken: SyncTokensDTO) {
        guard let encoded = encodeSyncTokens(syncToken) else { return }
        let clients = clients.filter { $0.subsidiaryCic == subsidiaryCic }
        for client in clients {
//            print("[WebSocketClientManager] enviando branch token: \(syncToken.branchToken, default: "nil") a employeeCic: \(client.employeeCic)")
            client.ws.send(encoded)
        }
    }

    private func encodeSyncTokens(_ parameters: SyncTokensDTO) -> String? {
        guard let data = try? JSONEncoder().encode(parameters) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
