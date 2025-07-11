import Vapor
//MARK: Session Parameters
struct LogInParameters: Content {
    let username: String
    let password: String
}
struct RegisterParameters: Content {
    let company: CompanyDTO
    let subsidiaryImage: ImageURLDTO?
    let subsidiary: SubsidiaryDTO
    let employeeImage: ImageURLDTO?
    let employee: EmployeeDTO
}
struct SessionConfig: Content {
    let companyId: UUID
    let subsidiaryId: UUID
    let employeeId: UUID
}
//MARK: Sync Parameters
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
struct RegisterSaleParameters: Content {
    let subsidiaryId: UUID
    let employeeId: UUID
    let customerId: UUID?
    let paymentType: String
    let cart: CartDTO
}
