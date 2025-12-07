import Fluent
import Foundation
import struct Foundation.UUID

final class Customer: Model, @unchecked Sendable {
    static let schema = "customers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "customer_cic") var customerCic: String
    @Field(key: "name") var name: String
    @Field(key: "lastName") var lastName: String?
    @Field(key: "totalDebt") var totalDebt: Int
    @Field(key: "creditScore") var creditScore: Int
    @Field(key: "creditDays") var creditDays: Int
    @Field(key: "isCreditLimitActive") var isCreditLimitActive: Bool
    @Field(key: "isCreditLimit") var isCreditLimit: Bool
    @Field(key: "isDateLimitActive") var isDateLimitActive: Bool
    @Field(key: "isDateLimit") var isDateLimit: Bool
    @Field(key: "dateLimit") var dateLimit: Date
    @Field(key: "firstDatePurchaseWithCredit") var firstDatePurchaseWithCredit: Date?
    @Field(key: "lastDatePurchase") var lastDatePurchase: Date
    @Field(key: "phoneNumber") var phoneNumber: String?
    @Field(key: "creditLimit") var creditLimit: Int
    @Field(key: "imageUrl") var imageUrl: String?
    @Field(key: "syncToken") var syncToken: Int64
    
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
        syncToken: Int64,
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
        self.syncToken = syncToken
        self.imageUrl = imageUrl
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
