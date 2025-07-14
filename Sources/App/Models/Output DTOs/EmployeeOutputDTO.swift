import Foundation
import Vapor

struct EmployeeOutputDTO: Content {
    let id: UUID
    let user: String
    let name: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let role: String
    let active: Bool
    let syncToken: Int64
    let subsidiaryID: UUID
    let imageUrlId: UUID?
    let createdAt: Date
    let updatedAt: Date
}
