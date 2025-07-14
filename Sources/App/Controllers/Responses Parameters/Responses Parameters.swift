import Vapor
//MARK: Response Parameters
struct DefaultResponse: Content {
    let code: Int
    let message: String
    init(code: Int = 200, message: String = "OK") {
        self.code = code
        self.message = message
    }
}
struct PayCustomerDebtResponse: Content {
    let customerId: UUID
    let change: Int
}
//MARK: Sync Response Parameters
struct SyncCompanyResponse: Encodable {
    let companyDTO: CompanyOutputDTO?
}
//struct SyncCustomersResponse: Encodable {
//    let customersDTOs: [CustomerOutputDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncEmployeesResponse: Encodable {
//    let employeesDTOs: [EmployeeOutputDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncImageUrlResponse: Encodable {
//    let imagesUrlDTOs: [ImageURLOutputDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncProductsResponse: Encodable {
//    let productsDTOs: [ProductOutputDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncSalesResponse: Encodable {
//    let salesDTOs: [SaleOutputDTO]
//    let syncIds: VerifySyncParameters
//}
//struct SyncSubsidiariesResponse: Encodable {
//    let subsidiariesDTOs: [SubsidiaryOutputDTO]
//    let syncIds: VerifySyncParameters
//}
//MARK: SubResponse Parameters
struct VerifySyncParameters: Content {
    let imageLastUpdate: UUID
    let companyLastUpdate: UUID
    let subsidiaryLastUpdate: UUID
    let customerLastUpdate: UUID
    let productLastUpdate: UUID
    let employeeLastUpdate: UUID
    let saleLastUpdate: UUID
}
