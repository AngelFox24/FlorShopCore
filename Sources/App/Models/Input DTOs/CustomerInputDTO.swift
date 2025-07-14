import Foundation

struct CustomerInputDTO: Decodable {
    let id: UUID?
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
    let companyID: UUID
    let imageUrl: ImageURLInputDTO?
}
