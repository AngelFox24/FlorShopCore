import Fluent
import Foundation
import struct Foundation.UUID

final class Sale: Model, @unchecked Sendable {
    static let schema = "sales"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "paymentType") var paymentType: String
    @Field(key: "saleDate") var saleDate: Date
    @Field(key: "total") var total: Int
    @Field(key: "syncToken") var syncToken: Int64
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "subsidiary_id") var subsidiary: Subsidiary
    @Parent(key: "employee_id") var employee: Employee
    @OptionalParent(key: "customer_id") var customer: Customer?
    
    @Children(for: \.$sale) var toSaleDetail: [SaleDetail]
    
    init() { }
    
    init(
        id: UUID? = nil,
        paymentType: String,
        saleDate: Date,
        total: Int,
        syncToken: Int64,
        subsidiaryID: Subsidiary.IDValue,
        employeeID: Employee.IDValue,
        customerID: Customer.IDValue?
    ) {
        self.id = id
        self.paymentType = paymentType
        self.saleDate = saleDate
        self.total = total
        self.syncToken = syncToken
        self.$subsidiary.id = subsidiaryID
        self.$employee.id = employeeID
        self.$customer.id = customerID
    }
}
