//
//  VerifySyncController.swift
//  FlorApiRestV1
//
//  Created by Angel Curi Laurente on 05/10/2024.
//
import Fluent
import Vapor

struct VerifySyncController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let subsidiaries = routes.grouped("verifySync")
        subsidiaries.post(use: getTokens)
        // Nuevo endpoint WebSocket sin afectar el anterior
        subsidiaries.webSocket("ws", onUpgrade: handleWebSocket)
    }
    func getTokens(req: Request) async throws -> VerifySyncParameters {
        return SyncTimestamp.shared.getLastSyncDate()
    }
    func handleWebSocket(req: Request, ws: WebSocket) {
        print("✅ Cliente WebSocket conectado")
        
        // Solo agregas el cliente, el envío inicial ya lo maneja WebSocketNotifier
        WebSocketNotifier.shared.addClient(ws)
        
        ws.onClose.whenComplete { _ in
            print("❌ Cliente desconectado")
        }
    }
}
