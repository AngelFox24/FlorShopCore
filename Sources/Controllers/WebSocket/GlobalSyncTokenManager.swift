import Vapor
import Fluent

actor GlobalSyncTokenManager {
    private var currentToken: Int64

    init(initialValue: Int64) {
        self.currentToken = initialValue
    }

    func nextToken() -> Int64 {
        currentToken += 1
        return currentToken
    }

    func tokenValue() -> Int64 {
        return currentToken
    }
    
    static func makeSyncTokenManager(db: any Database) async throws -> GlobalSyncTokenManager {
        let max1 = try await Company.query(on: db).max(\.$syncToken) ?? 0
        let max2 = try await Subsidiary.query(on: db).max(\.$syncToken) ?? 0
        let max3 = try await Product.query(on: db).max(\.$syncToken) ?? 0
        let max4 = try await Customer.query(on: db).max(\.$syncToken) ?? 0
        let max5 = try await Employee.query(on: db).max(\.$syncToken) ?? 0
        
        let initialToken = max(max1, max2, max3, max4, max5)
        return GlobalSyncTokenManager(initialValue: initialToken)
    }
}
