import Foundation

struct ImageURLInputDTO: Decodable {
    let id: UUID?
    let imageUrl: String?
    let imageHash: String?
    let imageData: Data?
}
