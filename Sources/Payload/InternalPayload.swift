import Foundation
import JWT

struct InternalPayload: JWTPayload {
    var sub: SubjectClaim       //user_cic
    var companyCic: String
    var subsidiaryCic: String
    var isOwner: Bool
    var type: String            //type of token
    var iss: IssuerClaim        //signer
    var iat: IssuedAtClaim      //generated date
    var exp: ExpirationClaim    //expiration date

    init(
        sub: SubjectClaim,
        companyCic: String,
        subsidiaryCic: String,
        isOwner: Bool = false,
        issuedAt: Date,
        expiration: Date
    ) {
        self.sub = sub
        self.companyCic = companyCic
        self.subsidiaryCic = subsidiaryCic
        self.isOwner = isOwner
        self.type = "internal"
        self.iss = .init(value: "FlorShopCore")
        self.iat = .init(value: issuedAt)
        self.exp = .init(value: expiration)
    }

    func verify(using signer: some JWTAlgorithm) throws {
        try exp.verifyNotExpired()
    }
}
