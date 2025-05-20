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
        print("Api version 2.0")
        return await SyncTimestamp.shared.getLastSyncDate()
    }
    func handleWebSocket(req: Request, ws: WebSocket) async {
        print("WebSocket version 2.0")
        try? await WebSocketClientManager.shared.addClient(ws)
    }
}
