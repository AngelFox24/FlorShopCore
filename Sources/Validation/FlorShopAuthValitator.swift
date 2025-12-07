import Vapor
import Fluent
import JWT

actor FlorShopAuthValitator {
    private let jwksURL:URI
    private var cachedJWKS: JWKS?
    private var eTag: String?
    private var expirationDate: Date?
    
    init(jwksURL: String = "https://auth.mrangel.dev") {
        self.jwksURL = URI(string: jwksURL + "/auth")
    }
    
    func verifyToken(_ token: String, client: any Client) async throws -> ScopedTokenPayload {
        // 1️⃣ Obtener las llaves públicas (puedes cachearlas luego)
        let jwks = try await getJWKS(client: client)

        // 2️⃣ Configurar los signers con esas llaves
        let keyCollection = JWTKeyCollection()
        try await keyCollection.add(jwks: jwks)

        // 4️⃣ Verificar la firma y decodificar el payload
        let payload = try await keyCollection.verify(token, as: ScopedTokenPayload.self)
        
        // 5️⃣ Crear el objeto UserIdentityDTO
        return payload
    }
    private func getJWKS(client: any Client) async throws -> JWKS {
        // ✅ Si sigue siendo válido según Cache-Control
        if let cachedJWKS, let expirationDate, Date() < expirationDate {
            return cachedJWKS
        }
        
        var headers = HTTPHeaders()
        if let eTag {
            headers.add(name: .ifNoneMatch, value: eTag)
        }
        
        let response = try await client.get(jwksURL, headers: headers)
        
        switch response.status {
        case .ok:
            let jwks = try response.content.decode(JWKS.self)
            cachedJWKS = jwks
            if let cacheControl = response.headers.first(name: .cacheControl),
               let maxAge = parseMaxAge(from: cacheControl) {
                expirationDate = Date().addingTimeInterval(TimeInterval(maxAge))
            }
            eTag = response.headers.first(name: .eTag)
            return jwks
            
        case .notModified:
            // 🔁 Reusar cache solo si existe
            guard let cached = cachedJWKS else {
                // No tenemos cache, volver a descargar
                let freshResponse = try await client.get(jwksURL)
                let jwks = try freshResponse.content.decode(JWKS.self)
                cachedJWKS = jwks
                return jwks
            }
            return cached
            
        default:
            throw Abort(.internalServerError, reason: "Failed to fetch JWKS: \(response.status.code)")
        }
    }
    private func parseMaxAge(from cacheControl: String) -> Int? {
        // Ejemplo: "public, max-age=12345"
        let parts = cacheControl.split(separator: ",")
        for part in parts {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("max-age="),
               let value = Int(trimmed.replacingOccurrences(of: "max-age=", with: "")) {
                return value
            }
        }
        return nil
    }
}
