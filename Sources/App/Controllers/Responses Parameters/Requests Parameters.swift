import Vapor
//MARK: Session Parameters
struct LogInParameters: Content {
    let username: String
    let password: String
}
struct RegisterParameters: Decodable {
    let company: CompanyInputDTO
    let subsidiary: SubsidiaryInputDTO
    let employee: EmployeeInputDTO
}
struct SessionConfig: Content {
    let companyId: UUID
    let subsidiaryId: UUID
    let employeeId: UUID
}
//MARK: Sync Parameters
struct SyncInputParameters: Decodable {
    let syncToken: Int64
}
struct SyncOutputParameters: Content {
    let images: [ImageURLOutputDTO]
    let company: CompanyOutputDTO?
    let subsidiaries: [SubsidiaryOutputDTO]
    let employees: [EmployeeOutputDTO]
    let customers: [CustomerOutputDTO]
    let products: [ProductOutputDTO]
    let sales: [SaleOutputDTO]
    let salesDetail: [SaleDetailOutputDTO]
    let isUpToDate: Bool
    
    static func empty() -> Self {
        return .init(
            images: [],
            company: nil,
            subsidiaries: [],
            employees: [],
            customers: [],
            products: [],
            sales: [],
            salesDetail: [],
            isUpToDate: true
        )
    }
}

struct SyncCompanyParameters: Content {
    let updatedSince: Date
    let syncIds: VerifySyncParameters
}
struct SyncImageParameters: Content {
    let updatedSince: Date
    let syncIds: VerifySyncParameters
}
struct SyncFromCompanyParameters: Content {
    let companyId: UUID
    let updatedSince: Date
    let syncIds: VerifySyncParameters
}
struct SyncFromSubsidiaryParameters: Content {
    let subsidiaryId: UUID
    let updatedSince: Date
    let syncIds: VerifySyncParameters
}
//MARK: Request Parameters
struct PayCustomerDebtParameters: Content {
    let customerId: UUID
    let amount: Int
}
struct RegisterSaleParameters: Decodable {
    let subsidiaryId: UUID
    let employeeId: UUID
    let customerId: UUID?
    let paymentType: String
    let cart: CartInputDTO
}
