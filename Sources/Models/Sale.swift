import Fluent
import Foundation
import struct Foundation.UUID
import FlorShopDTOs

final class Sale: Model, @unchecked Sendable {
    static let schema = "sales"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "payment_type") var paymentType: PaymentType
    @Field(key: "sale_date") var saleDate: Date
    @Field(key: "total") var total: Int
    @Field(key: "subsidiary_cic") var subsidiaryCic: String
    @Field(key: "customer_cic") var customerCic: String?
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "subsidiary_id") var subsidiary: Subsidiary
    @Parent(key: "employee_subsidiary_id") var employeeSubsidiary: EmployeeSubsidiary
    @OptionalParent(key: "customer_id") var customer: Customer?
    
    @Children(for: \.$sale) var toSaleDetail: [SaleDetail]
    
    init() { }
    
    init(
        id: UUID? = nil,
        paymentType: PaymentType,
        saleDate: Date,
        total: Int,
        subsidiaryCic: String,
        customerCic: String?,
        subsidiaryID: Subsidiary.IDValue,
        employeeSubsidiaryID: EmployeeSubsidiary.IDValue,
        customerID: Customer.IDValue?
    ) {
        self.id = id
        self.paymentType = paymentType
        self.saleDate = saleDate
        self.total = total
        self.subsidiaryCic = subsidiaryCic
        self.customerCic = customerCic
        self.$subsidiary.id = subsidiaryID
        self.$employeeSubsidiary.id = employeeSubsidiaryID
        self.$customer.id = customerID
    }
}
