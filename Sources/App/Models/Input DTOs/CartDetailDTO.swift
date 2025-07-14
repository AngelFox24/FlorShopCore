import Foundation

struct CartDetailInputDTO: Decodable {
    let id: UUID?
    let quantity: Int
    let subtotal: Int
    let productId: UUID
}
