import Foundation
import Vapor

struct CompanyOutputDTO: Content {
    let id: UUID
    let companyName: String
    let ruc: String
    let syncToken: Int64
    let createdAt: Date
    let updatedAt: Date
}
