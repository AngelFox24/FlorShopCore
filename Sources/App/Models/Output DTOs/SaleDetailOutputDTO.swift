import Foundation
import Vapor

struct SaleDetailOutputDTO: Content {
    let id: UUID
    let productName: String
    let barCode: String
    let quantitySold: Int
    let subtotal: Int
    let unitType: String
    let unitCost: Int
    let unitPrice: Int
    let syncToken: Int64
    let saleID: UUID
    let imageUrlId: UUID?
    let createdAt: Date
    let updatedAt: Date
}
