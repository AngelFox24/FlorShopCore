import Vapor
import FlorShop_DTOs
//MARK: Session Parameters
struct LogInParameters: Content {
    let username: String
    let password: String
}
struct RegisterParameters: Decodable {
    let company: CompanyServerDTO
    let subsidiary: SubsidiaryServerDTO
    let employee: EmployeeServerDTO
}
struct SessionConfig: Content {
    let companyId: UUID
    let subsidiaryId: UUID
    let employeeId: UUID
}
//MARK: Sync Parameters
struct SyncServerParameters: Decodable {
    let syncToken: Int64
    let sessionConfig: SessionConfig
}
struct SyncClientParameters: Content {
    let images: [ImageURLClientDTO]
    let company: CompanyClientDTO?
    let subsidiaries: [SubsidiaryClientDTO]
    let employees: [EmployeeClientDTO]
    let customers: [CustomerClientDTO]
    let products: [ProductClientDTO]
    let sales: [SaleClientDTO]
    let salesDetail: [SaleDetailClientDTO]
    let lastToken: Int64
    let isUpToDate: Bool
    
    static func empty(lastToken: Int64) -> Self {
        return .init(
            images: [],
            company: nil,
            subsidiaries: [],
            employees: [],
            customers: [],
            products: [],
            sales: [],
            salesDetail: [],
            lastToken: lastToken,
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
    let cart: CartServerDTO
}
