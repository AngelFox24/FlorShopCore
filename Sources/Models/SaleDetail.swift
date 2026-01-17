import Fluent
import Foundation
import struct Foundation.UUID
import FlorShopDTOs

final class SaleDetail: Model, @unchecked Sendable {
    static let schema = "saleDetails"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "productName") var productName: String
    @Field(key: "barCode") var barCode: String
    @Field(key: "quantitySold") var quantitySold: Int
    @Field(key: "subtotal") var subtotal: Int
    @Field(key: "unitType") var unitType: UnitType
    @Field(key: "unitCost") var unitCost: Int
    @Field(key: "unitPrice") var unitPrice: Int
    @Field(key: "imageUrl") var imageUrl: String?
//    @Field(key: "syncToken") var syncToken: Int64
    
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
//        syncToken: Int64,
        imageUrl: String?,
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
//        self.syncToken = syncToken
        self.$sale.id = saleID
    }
}
