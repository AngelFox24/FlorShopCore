import FluentPostgresDriver
import Vapor

extension Application {
    func setJsonDecoder() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        ContentConfiguration.global.use(encoder: encoder, for: .json)
        ContentConfiguration.global.use(decoder: decoder, for: .json)
    }
}

