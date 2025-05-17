//
//  WebSocketNotifier.swift
//  FlorApiRestV1
//
//  Created by Angel Curi Laurente on 17/05/2025.
//
import Fluent
import Vapor
import NIOConcurrencyHelpers  // necesario para NIOLock

final class WebSocketNotifier {
    static let shared = WebSocketNotifier()

    private var clients: [WebSocket] = []
    private let lock = NIOLock()

    private init() {
        // Conectarse como observador
        SyncTimestamp.shared.onUpdate = { [weak self] parameters in
            self?.broadcast(parameters)
        }
    }

    func addClient(_ ws: WebSocket) {
        lock.withLock {
            clients.append(ws)
            if let syncParameters = encodeSyncParameters(SyncTimestamp.shared.getLastSyncDate()) {
                ws.send(syncParameters)
            }
        }

        ws.onClose.whenComplete { [weak self] _ in
            self?.removeClient(ws)
        }
    }

    private func removeClient(_ ws: WebSocket) {
        lock.withLock {
            clients.removeAll { $0 === ws }
        }
    }

    private func broadcast(_ parameters: VerifySyncParameters) {
        guard let syncParameters = encodeSyncParameters(parameters) else { return }
        
        lock.withLock {
            clients.forEach { $0.send(syncParameters) }
        }
    }
    
    private func encodeSyncParameters(_ parameters: VerifySyncParameters) -> String? {
        guard let data = try? JSONEncoder().encode(parameters) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
