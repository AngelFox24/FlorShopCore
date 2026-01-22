import Foundation
import JWT

struct ScopedTokenPayload: JWTPayload {
    var sub: SubjectClaim           // user_cic
    var aud: AudienceClaim
    var companyCic: String
    var subsidiaryCic: String
    var isOwner: Bool
    var type: String
    var iss: IssuerClaim
    var iat: IssuedAtClaim
    var exp: ExpirationClaim

    init(
        subject: String,
        companyCic: String,
        subsidiaryCic: String,
        isOwner: Bool = false,
        issuedAt: Date,
        expiration: Date
    ) {
        self.sub = .init(value: subject)
        self.aud = .init(value: ["FlorShopCore"])
        self.companyCic = companyCic
        self.subsidiaryCic = subsidiaryCic
        self.isOwner = isOwner
        self.type = "scoped"
        self.iss = .init(value: "https://auth.mrangel.dev")
        self.iat = .init(value: issuedAt)
        self.exp = .init(value: expiration)
    }

    func verify(using signer: some JWTAlgorithm) throws {
        try exp.verifyNotExpired()
    }
}
