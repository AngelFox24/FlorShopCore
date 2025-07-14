import Foundation

struct SubsidiaryInputDTO: Decodable {
    let id: UUID?
    let name: String
    let companyID: UUID
    let imageUrl: ImageURLInputDTO?
}
