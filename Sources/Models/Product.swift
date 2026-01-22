import Fluent
import Foundation
import struct Foundation.UUID
import FlorShopDTOs

final class Product: Model, @unchecked Sendable {
    static let schema = "products"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "product_cic") var productCic: String
    @Field(key: "bar_code") var barCode: String
    @Field(key: "product_name") var productName: String
    @Field(key: "unit_type") var unitType: UnitType
    @Field(key: "image_url") var imageUrl: String?
    @Field(key: "company_cic") var companyCic: String
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationships
    @Parent(key: "company_id") var company: Company
    @Children(for: \.$product) var toProductSubsidiary: [ProductSubsidiary]
    
    init() { }
    
    init(
        productCic: String,
        barCode: String,
        productName: String,
        unitType: UnitType,
        imageUrl: String?,
        companyCic: String,
        companyID: Company.IDValue
    ) {
        self.productCic = productCic
        self.barCode = barCode
        self.productName = productName
        self.unitType = unitType
        self.imageUrl = imageUrl
        self.companyCic = companyCic
        self.$company.id = companyID
    }
}

extension Product {
    static func findProduct(productCic: String, on db: any Database) async throws -> Product? {
        return try await Product.query(on: db)
            .filter(Product.self, \.$productCic == productCic)
            .first()
    }
    static func productNameExist(productName: String, productCic: String? = nil, on db: any Database) async throws -> Bool {
        guard productName != "" else { return true }

        let query = Product.query(on: db)
            .filter(\.$productName == productName)

        // Si viene productCic, excluirlo del query
        if let productCic {
            query.filter(\.$productCic != productCic)
        }

        let result = try await query
            .limit(1)
            .first()

        return result != nil
    }
}
