import Foundation
import Vapor

struct SaleOutputDTO: Content {
    let id: UUID
    let paymentType: String
    let saleDate: Date
    let total: Int
    let syncToken: Int64
    let subsidiaryId: UUID
    let customerId: UUID?
    let employeeId: UUID
    let saleDetail: [SaleDetailOutputDTO]
    let createdAt: Date
    let updatedAt: Date
}
