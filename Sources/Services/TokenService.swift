import Foundation
import Vapor
import FlorShopDTOs

struct TokenService {
    static func generateInternalToken(scopedToken: ScopedTokenPayload, req: Request) async throws -> String {
        let now = Date()
        let exp = now.addingTimeInterval(3600) // 1 hora
        let payload = InternalPayload(
            sub: scopedToken.sub,
            companyCic: scopedToken.companyCic,
            subsidiaryCic: scopedToken.subsidiaryCic,
            isOwner: scopedToken.isOwner,
            issuedAt: now,
            expiration: exp
        )
        let token = try await req.jwt.sign(payload, kid: .init(string: JWTKeyID.internalToken.rawValue))
        return token
    }
}
