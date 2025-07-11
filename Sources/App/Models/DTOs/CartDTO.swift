import Foundation
import Vapor

struct CartDTO: Content {
    let cartDetails: [CartDetailDTO]
    let total: Int
}
