//
//  Subsidiary.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Foundation
import struct Foundation.UUID

final class Subsidiary: Model, Syncronizable, @unchecked Sendable {
    
    static let schema = "subsidiaries"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    @Field(key: "syncToken")
    var syncToken: Int64
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "company_id")
    var company: Company
    
    @OptionalParent(key: "imageUrl_id")
    var imageUrl: ImageUrl?
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        syncToken: Int64,
        companyID: Company.IDValue,
        imageUrlID: ImageUrl.IDValue?
    ) {
        self.id = id
        self.name = name
        self.syncToken = syncToken
        self.$company.id = companyID
        self.$imageUrl.id = imageUrlID
    }
}
