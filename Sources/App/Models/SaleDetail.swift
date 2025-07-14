//
//  SaleDetail.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Foundation
import struct Foundation.UUID

final class SaleDetail: Model, Syncronizable, @unchecked Sendable {
    static let schema = "saleDetails"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "productName")
    var productName: String
    @Field(key: "barCode")
    var barCode: String
    @Field(key: "quantitySold")
    var quantitySold: Int
    @Field(key: "subtotal")
    var subtotal: Int
    @Field(key: "unitType")
    var unitType: String
    @Field(key: "unitCost")
    var unitCost: Int
    @Field(key: "unitPrice")
    var unitPrice: Int
    @Field(key: "syncToken")
    var syncToken: Int64
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "sale_id")
    var sale: Sale
    
    //Imagen se debe pedir en el JSON
    @OptionalParent(key: "imageUrl_id")
    var imageUrl: ImageUrl?
    
    init() { }
    
    init(
        id: UUID? = nil,
        productName: String,
        barCode: String,
        quantitySold: Int,
        subtotal: Int,
        unitType: String,
        unitCost: Int,
        unitPrice: Int,
        syncToken: Int64,
        saleID: Sale.IDValue,
        imageUrlID: ImageUrl.IDValue?
    ) {
        self.id = id
        self.productName = productName
        self.barCode = barCode
        self.quantitySold = quantitySold
        self.subtotal = subtotal
        self.unitType = unitType
        self.unitCost = unitCost
        self.unitPrice = unitPrice
        self.syncToken = syncToken
        self.$sale.id = saleID
        self.$imageUrl.id = imageUrlID
    }
}
