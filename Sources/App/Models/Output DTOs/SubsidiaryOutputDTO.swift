import Foundation
import Vapor

struct SubsidiaryOutputDTO: Content {
    let id: UUID
    let name: String
    let syncToken: Int64
    let companyID: UUID
    let imageUrlId: UUID?
    let createdAt: Date
    let updatedAt: Date
}
