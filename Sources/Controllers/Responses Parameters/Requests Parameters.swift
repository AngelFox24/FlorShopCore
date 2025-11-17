import Vapor
import FlorShopDTOs
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
    let globalSyncToken: Int64
    let branchSyncToken: Int64
}

struct SyncClientParameters: Content {
    let company: CompanyClientDTO?
    let subsidiaries: [SubsidiaryClientDTO]
    let employees: [EmployeeClientDTO]
    let customers: [CustomerClientDTO]
    let products: [ProductClientDTO]
    let productsSubsidiary: [ProductSubsidiaryClientDTO]
    let sales: [SaleClientDTO]
    let salesDetail: [SaleDetailClientDTO]
    let lastGlobalToken: Int64
    let isGlobalUpToDate: Bool
    let lastBranchToken: Int64
    let isBranchUpToDate: Bool
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
