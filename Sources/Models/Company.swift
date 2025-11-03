import Fluent
import Foundation
import struct Foundation.UUID

protocol Syncronizable {
    var syncToken: Int64 { get }
}

final class Company: Model, Syncronizable, @unchecked Sendable {
    static let schema = "companies"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "companyName")
    var companyName: String
    @Field(key: "ruc")
    var ruc: String
    @Field(key: "syncToken")
    var syncToken: Int64
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    //MARK: Relationship
    @Children(for: \.$company)
    var toSubsidiary: [Subsidiary]
    init() { }
    
    init(
        id: UUID? = nil,
        companyName: String,
        ruc: String,
        syncToken: Int64
    ) {
        self.id = id
        self.companyName = companyName
        self.ruc = ruc
        self.syncToken = syncToken
    }
}
