import Vapor
//MARK: Response Parameters
protocol Shareable {
    func broadCast(webSocket: WebSocketClientManager)
}
extension Shareable {
    func broadCast(webSocket: WebSocketClientManager) {
        Task {
            let syncParameters = await SyncTimestamp.shared.getLastSyncDate()
            await webSocket.broadcast(syncParameters)
        }
    }
}
struct DefaultResponse: Content, Shareable {
    let code: Int
    let message: String
    init(code: Int, message: String, webSocket: WebSocketClientManager) {
        self.code = code
        self.message = message
        if self.code == 200 {
            broadCast(webSocket: webSocket)
        }
    }
}
struct PayCustomerDebtResponse: Content, Shareable {
    let customerId: UUID
    let change: Int
    init(customerId: UUID, change: Int, webSocket: WebSocketClientManager) {
        self.customerId = customerId
        self.change = change
        broadCast(webSocket: webSocket)
    }
}
//MARK: Sync Response Parameters
struct SyncCompanyResponse: Content {
    let companyDTO: CompanyDTO?
    let syncIds: VerifySyncParameters
}
struct SyncCustomersResponse: Content {
    let customersDTOs: [CustomerDTO]
    let syncIds: VerifySyncParameters
}
struct SyncEmployeesResponse: Content {
    let employeesDTOs: [EmployeeDTO]
    let syncIds: VerifySyncParameters
}
struct SyncImageUrlResponse: Content {
    let imagesUrlDTOs: [ImageURLDTO]
    let syncIds: VerifySyncParameters
}
struct SyncProductsResponse: Content {
    let productsDTOs: [ProductDTO]
    let syncIds: VerifySyncParameters
}
struct SyncSalesResponse: Content {
    let salesDTOs: [SaleDTO]
    let syncIds: VerifySyncParameters
}
struct SyncSubsidiariesResponse: Content {
    let subsidiariesDTOs: [SubsidiaryDTO]
    let syncIds: VerifySyncParameters
}
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
