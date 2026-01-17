import Foundation
import Vapor
import Fluent

actor BranchScopedSyncTokenManager {
    private var tokens: [String: Int64] = [:]

    init(initialValues: [String: Int64]) {
        self.tokens = initialValues
    }

    func nextToken(subsidiaryCic: String) -> Int64 {
        let next = (tokens[subsidiaryCic] ?? 0) + 1
        tokens[subsidiaryCic] = next
        return next
    }

    func tokenValue(subsidiaryCic: String) -> Int64 {
        return tokens[subsidiaryCic] ?? 0
    }
    
    func allTokens() -> [String: Int64] {
        return tokens
    }

//    static func makeManager(db: any Database) async throws -> BranchScopedSyncTokenManager {
//        // Consultamos el máximo token por sucursal
//        let results = try await Subsidiary.query(on: db).all()
//        var map: [String: Int64] = [:]
//        for branch in results {
//            let max1 = try await EmployeeSubsidiary.query(on: db)
//                .filter(\.$subsidiary.$id == branch.id!)
//                .max(\.$syncToken) ?? 0
//            let max2 = try await ProductSubsidiary.query(on: db)
//                .filter(\.$subsidiary.$id == branch.id!)
//                .max(\.$syncToken) ?? 0
//            let max3 = try await Sale.query(on: db)
//                .filter(\.$subsidiary.$id == branch.id!)
//                .max(\.$syncToken) ?? 0
//            let max4 = try await SaleDetail.query(on: db)
//                .join(Sale.self, on: \Sale.$id == \SaleDetail.$id)
//                .filter(Sale.self, \.$subsidiary.$id == branch.id!)
//                .max(\.$syncToken) ?? 0
//
//            map[branch.subsidiaryCic] = max(max1, max2, max3, max4)
//        }
//        return BranchScopedSyncTokenManager(initialValues: map)
//    }
}
