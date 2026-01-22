import Fluent
import Foundation
import struct Foundation.UUID
import FlorShopDTOs

final class SaleDetail: Model, @unchecked Sendable {
    static let schema = "sale_details"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "product_name") var productName: String
    @Field(key: "bar_code") var barCode: String
    @Field(key: "quantity_sold") var quantitySold: Int
    @Field(key: "subtotal") var subtotal: Int
    @Field(key: "unit_type") var unitType: UnitType
    @Field(key: "unit_cost") var unitCost: Int
    @Field(key: "unit_price") var unitPrice: Int
    @Field(key: "image_url") var imageUrl: String?
    @Field(key: "subsidiary_cic") var subsidiaryCic: String
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "sale_id") var sale: Sale
    
    init() { }
    
    init(
        id: UUID? = nil,
        productName: String,
        barCode: String,
        quantitySold: Int,
        subtotal: Int,
        unitType: UnitType,
        unitCost: Int,
        unitPrice: Int,
        imageUrl: String?,
        subsidiaryCic: String,
        saleID: Sale.IDValue
    ) {
        self.id = id
        self.productName = productName
        self.barCode = barCode
        self.quantitySold = quantitySold
        self.subtotal = subtotal
        self.unitType = unitType
        self.unitCost = unitCost
        self.unitPrice = unitPrice
        self.imageUrl = imageUrl
        self.subsidiaryCic = subsidiaryCic
        self.$sale.id = saleID
    }
}
