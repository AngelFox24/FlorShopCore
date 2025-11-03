//
//  ImageUrl.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Foundation
import struct Foundation.UUID

final class ImageUrl: Model, Syncronizable, @unchecked Sendable {
    static let schema = "imageUrls"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "imageUrl")
    var imageUrl: String
    @Field(key: "imageHash")
    var imageHash: String
    @Field(key: "syncToken")
    var syncToken: Int64
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    //MARK: Relationship
    @Children(for: \.$imageUrl)
    var toSubsidiary: [Subsidiary]
    
    @Children(for: \.$imageUrl)
    var toSaleDetail: [SaleDetail]
    
    @Children(for: \.$imageUrl)
    var toCustomer: [Customer]
    
    @Children(for: \.$imageUrl)
    var toEmployee: [Employee]
    
    @Children(for: \.$imageUrl)
    var toProduct: [Product]
    
    init() { }
    
    init(
        id: UUID? = nil,
        imageUrl: String,
        imageHash: String,
        syncToken: Int64
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.imageHash = imageHash
        self.syncToken = syncToken
    }
}
