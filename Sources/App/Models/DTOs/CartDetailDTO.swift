import Foundation
import Vapor

struct CartDetailDTO: Content {
    let quantity: Int
    let subtotal: Int
    let productId: UUID
}
