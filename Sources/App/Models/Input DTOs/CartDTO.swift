import Foundation

struct CartInputDTO: Decodable {
    let id: UUID?
    let cartDetails: [CartDetailInputDTO]
    let total: Int
}
