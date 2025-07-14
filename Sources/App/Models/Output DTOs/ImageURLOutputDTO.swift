import Foundation
import Vapor

struct ImageURLOutputDTO: Content {
    let id: UUID
    let imageUrl: String
    let imageHash: String
    let syncToken: Int64
    let createdAt: Date
    let updatedAt: Date
}
