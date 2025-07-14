import Foundation

struct CompanyInputDTO: Decodable {
    let id: UUID?
    let companyName: String
    let ruc: String
}
