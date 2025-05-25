import Fluent
import Vapor
import NIOConcurrencyHelpers  // necesario para NIOLock

struct WebSocketClient {
    let socket: WebSocket
    let alias: UUID = UUID()
    var lastPong: Date
}
actor WebSocketClientManager {
    private var clients: [WebSocketClient] = []

    func addClient(_ ws: WebSocket) async throws {
        let newClient = WebSocketClient(socket: ws, lastPong: Date())
        clients.append(newClient)
        print("✅ Cliente WebSocket conectado, id: \(newClient.alias)")

        if let syncParameters = encodeSyncParameters(await SyncTimestamp.shared.getLastSyncDate()) {
            try await ws.send(syncParameters)
        }

//        ws.onPong { _, _ in
//            Task { await self.updatePong(for: ws) }
//        }
    }

    func updatePong(for ws: WebSocket) {
        print("📌 Pong Recibido no se sabe de quien")
        if let index = clients.firstIndex(where: { $0.socket === ws }) {
            print("📌 Pong Recibido de Cliente: \(clients[index].alias)")
            clients[index].lastPong = Date()
        }
    }

    func removeClient(_ ws: WebSocket) {
        let clientToRemove = clients.filter { $0.socket === ws }.first
        clients.removeAll { $0.socket === ws}
        print("❌ Cliente removido: \(String(describing: clientToRemove?.alias))")
    }

    func sendPingsAndClean() {
        let now = Date()
        let timeout: TimeInterval = 15

        print("📌 Enviando Ping a todos: \(clients.count)")

        clients = clients.filter { client in
            let alive = now.timeIntervalSince(client.lastPong) <= timeout
            if alive {
                print("📌 Enviando Ping a cliente activo: \(client.alias)")
                client.socket.sendPing()
            } else {
                print("❌ Cliente eliminado por inactividad: \(client.alias)")
            }
            return alive
        }
    }

    func broadcast(_ parameters: VerifySyncParameters) {
        guard let syncParameters = encodeSyncParameters(parameters) else { return }

        print("📌 Enviando mensajes a: \(clients.count) clientes")
        for client in clients {
            print("📌 Enviando mensaje a: \(client.alias)")
            client.socket.send(syncParameters)
        }
    }

    private func encodeSyncParameters(_ parameters: VerifySyncParameters) -> String? {
        guard let data = try? JSONEncoder().encode(parameters) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
