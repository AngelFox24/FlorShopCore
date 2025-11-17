import Fluent
import Vapor

struct Test: RouteCollection {
    let validator: FlorShopAuthValitator
    func boot(routes: any RoutesBuilder) throws {
        let test = routes.grouped("test")
        test.post(use: self.test)
    }
    @Sendable
    func test(req: Request) async throws -> Response {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)

        print("✅ Token válido para \(payload.companyCic), userCic: \(payload.sub.value)")
        return Response(status: .ok, body: .init(stringLiteral: "✅ Token válido para \(payload.companyCic), userCic: \(payload.sub.value)"))
    }
}
