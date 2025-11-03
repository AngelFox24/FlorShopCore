//
//  SyncTokenManager.swift
//  FlorApiRest
//
//  Created by Angel Curi Laurente on 11/07/2025.
//
import Vapor
import Fluent

actor SyncTokenManager {
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
    
    static func makeSyncTokenManager(db: any Database) async throws -> SyncTokenManager {
        let max1 = try await Company.query(on: db).max(\.$syncToken) ?? 0
        let max2 = try await Customer.query(on: db).max(\.$syncToken) ?? 0
        let max3 = try await Employee.query(on: db).max(\.$syncToken) ?? 0
        let max4 = try await ImageUrl.query(on: db).max(\.$syncToken) ?? 0
        let max5 = try await Product.query(on: db).max(\.$syncToken) ?? 0
        let max6 = try await Sale.query(on: db).max(\.$syncToken) ?? 0
        let max7 = try await SaleDetail.query(on: db).max(\.$syncToken) ?? 0
        let max8 = try await Subsidiary.query(on: db).max(\.$syncToken) ?? 0
        
        let initialToken = max(max1, max2, max3, max4, max5, max6, max7, max8)
        return SyncTokenManager(initialValue: initialToken)
    }
}
