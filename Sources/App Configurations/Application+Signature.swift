import Vapor
import JWT
import FlorShopDTOs

extension Application {
    public func setSignature() async {
        guard let internalKey = Environment.get(EnvironmentVariables.jwtHmacInternalKey.rawValue) else {
            fatalError("\(EnvironmentVariables.jwtHmacInternalKey) don't found in .env.\(self.environment)")
        }
        let hmacKey = HMACKey(from: internalKey)
        await self.jwt.keys.add(hmac: hmacKey, digestAlgorithm: .sha256, kid: .init(string: JWTKeyID.internalToken.rawValue))
    }
}
