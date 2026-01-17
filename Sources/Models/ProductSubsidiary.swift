import Fluent
import Foundation
import struct Foundation.UUID

final class ProductSubsidiary: Model, @unchecked Sendable {
    static let schema = "productSubsidiary"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "active") var active: Bool
    @Field(key: "expirationDate") var expirationDate: Date?
    @Field(key: "quantityStock") var quantityStock: Int
    @Field(key: "unitCost") var unitCost: Int
    @Field(key: "unitPrice") var unitPrice: Int
//    @Field(key: "syncToken") var syncToken: Int64
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationships
    @Parent(key: "product_id") var product: Product
    @Parent(key: "subsidiary_id") var subsidiary: Subsidiary
    
    init() { }
    
    init(
        active: Bool,
        expirationDate: Date? = nil,
        quantityStock: Int,
        unitCost: Int,
        unitPrice: Int,
//        syncToken: Int64,
        productID: Product.IDValue,
        subsidiaryID: Subsidiary.IDValue
    ) {
        self.active = active
        self.expirationDate = expirationDate
        self.quantityStock = quantityStock
        self.unitCost = unitCost
        self.unitPrice = unitPrice
//        self.syncToken = syncToken
        self.$product.id = productID
        self.$subsidiary.id = subsidiaryID
    }
}

extension ProductSubsidiary {
    static func findProductSubsidiary(productCic: String, subsisiaryCic: String, on db: any Database) async throws -> ProductSubsidiary? {
        try await ProductSubsidiary.query(on: db)
            .join(Subsidiary.self, on: \Subsidiary.$id == \ProductSubsidiary.$subsidiary.$id)
            .join(Product.self, on: \Product.$id == \ProductSubsidiary.$product.$id)
            .filter(Subsidiary.self, \.$subsidiaryCic == subsisiaryCic)
            .filter(Product.self, \.$productCic == productCic)
            .with(\.$product)
            .first()
    }
}
