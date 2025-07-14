import Foundation
import Vapor

struct CustomerOutputDTO: Content {
    let id: UUID
    let name: String
    let lastName: String
    let totalDebt: Int
    let creditScore: Int
    let creditDays: Int
    let isCreditLimitActive: Bool
    let isCreditLimit: Bool
    let isDateLimitActive: Bool
    let isDateLimit: Bool
    let dateLimit: Date
    var firstDatePurchaseWithCredit: Date?
    let lastDatePurchase: Date
    let phoneNumber: String
    let creditLimit: Int
    let syncToken: Int64
    let companyID: UUID
    let imageUrlId: UUID?
    let createdAt: Date
    let updatedAt: Date
}
