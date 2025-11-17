import Fluent
import Foundation
import struct Foundation.UUID

final class Company: Model, @unchecked Sendable {
    static let schema = "companies"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "company_cic") var companyCic: String
    @Field(key: "companyName") var companyName: String
    @Field(key: "ruc") var ruc: String
    @Field(key: "syncToken") var syncToken: Int64
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Children(for: \.$company) var toSubsidiary: [Subsidiary]
    
    init() { }
    
    init(
        companyCic: String,
        companyName: String,
        ruc: String,
        syncToken: Int64
    ) {
        self.companyCic = companyCic
        self.companyName = companyName
        self.ruc = ruc
        self.syncToken = syncToken
    }
}

extension Company {
    static func findCompany(companyCic: String, on db: any Database) async throws -> Company? {
        try await Company.query(on: db)
            .filter(Company.self, \.$companyCic == companyCic)
            .first()
    }
}
