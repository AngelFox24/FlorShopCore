import Fluent
import Foundation
import struct Foundation.UUID

final class Customer: Model, @unchecked Sendable {
    static let schema = "customers"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "customer_cic") var customerCic: String
    @Field(key: "name") var name: String
    @Field(key: "last_name") var lastName: String?
    @Field(key: "total_debt") var totalDebt: Int
    @Field(key: "credit_score") var creditScore: Int
    @Field(key: "credit_days") var creditDays: Int
    @Field(key: "is_credit_limit_active") var isCreditLimitActive: Bool
    @Field(key: "is_credit_limit") var isCreditLimit: Bool
    @Field(key: "is_date_limit_active") var isDateLimitActive: Bool
    @Field(key: "is_date_limit") var isDateLimit: Bool
    @Field(key: "date_limit") var dateLimit: Date
    @Field(key: "first_date_purchase_with_credit") var firstDatePurchaseWithCredit: Date?
    @Field(key: "last_date_purchase") var lastDatePurchase: Date
    @Field(key: "phone_number") var phoneNumber: String?
    @Field(key: "credit_limit") var creditLimit: Int
    @Field(key: "image_url") var imageUrl: String?
    @Field(key: "company_cic") var companyCic: String
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    
    //MARK: Relationship
    @Parent(key: "company_id") var company: Company
    @Children(for: \.$customer) var toSale: [Sale]
    
    init() { }
    
    init(
        customerCic: String,
        name: String,
        lastName: String?,
        totalDebt: Int,
        creditScore: Int,
        creditDays: Int,
        isCreditLimitActive: Bool,
        isCreditLimit: Bool,
        isDateLimitActive: Bool,
        isDateLimit: Bool,
        dateLimit: Date,
        firstDatePurchaseWithCredit: Date?,
        lastDatePurchase: Date,
        phoneNumber: String?,
        creditLimit: Int,
        imageUrl: String?,
        companyCic: String,
        companyID: Company.IDValue
    ) {
        self.customerCic = customerCic
        self.name = name
        self.lastName = lastName
        self.totalDebt = totalDebt
        self.creditScore = creditScore
        self.creditDays = creditDays
        self.isCreditLimitActive = isCreditLimitActive
        self.isCreditLimit = isCreditLimit
        self.isDateLimitActive = isDateLimitActive
        self.isDateLimit = isDateLimit
        self.dateLimit = dateLimit
        self.firstDatePurchaseWithCredit = firstDatePurchaseWithCredit
        self.lastDatePurchase = lastDatePurchase
        self.phoneNumber = phoneNumber
        self.creditLimit = creditLimit
        self.imageUrl = imageUrl
        self.companyCic = companyCic
        self.$company.id = companyID
    }
}

extension Customer {
    static func findCustomer(customerCic: String?, on db: any Database) async throws -> Customer? {
        guard let customerCic else { return nil }
        return try await Customer.query(on: db)
            .filter(Customer.self, \.$customerCic == customerCic)
            .first()
    }
}
