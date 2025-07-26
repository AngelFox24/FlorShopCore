import Fluent
import Vapor

struct SyncController: RouteCollection {
    let syncManager: SyncManager
    let syncLimit: Int = 50
    func boot(routes: any RoutesBuilder) throws {
        let subsidiaries = routes.grouped("sync")
        subsidiaries.post(use: self.sync)
        subsidiaries.webSocket("ws", onUpgrade: self.handleWebSocket)
    }
    @Sendable
    func sync(req: Request) async throws -> SyncClientParameters {
        print("Api version 2.0")
        let request = try req.content.decode(SyncServerParameters.self)
        let syncOutputParameters: SyncClientParameters = try await req.db.transaction { transaction in
            let clientToken = request.syncToken
            let lastToken = await syncManager.getLastSyncToken()
            guard clientToken < lastToken else {
                return SyncClientParameters.empty(lastToken: lastToken)
            }
            var tokenLimit = clientToken + Int64(syncLimit)
            if lastToken < tokenLimit {
                tokenLimit = lastToken
            }
            print("[SyncController] New Request, startToken: \(clientToken), endToken: \(tokenLimit)")
            async let images = self.getChangedImages(startToken: clientToken, endToken: tokenLimit, sessionConfig: request.sessionConfig, db: transaction)
            async let company = self.getChangedCompany(startToken: clientToken, endToken: tokenLimit, sessionConfig: request.sessionConfig, db: transaction)
            async let subsidiaries = self.getChangedSubsidiaries(startToken: clientToken, endToken: tokenLimit, sessionConfig: request.sessionConfig, db: transaction)
            async let employees = self.getChangedEmployees(startToken: clientToken, endToken: tokenLimit, sessionConfig: request.sessionConfig, db: transaction)
            async let customers = self.getChangedCustomers(startToken: clientToken, endToken: tokenLimit, sessionConfig: request.sessionConfig, db: transaction)
            async let products = self.getChangedProducts(startToken: clientToken, endToken: tokenLimit, sessionConfig: request.sessionConfig, db: transaction)
            async let sales = self.getChangedSales(startToken: clientToken, endToken: tokenLimit, sessionConfig: request.sessionConfig, db: transaction)
            async let salesDetail = self.getChangedSalesDetail(startToken: clientToken, endToken: tokenLimit, sessionConfig: request.sessionConfig, db: transaction)

            // Esperar todos en paralelo
            return SyncClientParameters(
                images: try await images.mapToListImageURLDTO(),
                company: try await company?.toCompanyDTO(),
                //Company puede ser nulo, casi siempre no se actualiza
                subsidiaries: try await subsidiaries.mapToListSubsidiaryDTO(),
                employees: try await employees.mapToListEmployeeDTO(),
                customers: try await customers.mapToListCustomerDTO(),
                products: try await products.mapToListProductDTO(),
                sales: try await sales.mapToListSaleDTO(),
                salesDetail: try await salesDetail.mapToListSaleDetailDTO(),
                lastToken: tokenLimit,
                isUpToDate: tokenLimit == lastToken
            )
        }
        return syncOutputParameters
    }
    @Sendable
    func handleWebSocket(req: Request, ws: WebSocket) async {
        print("WebSocket version 2.0")
        // Establece un intervalo de ping
        ws.pingInterval = .seconds(10)
        try? await syncManager.addClient(ws: ws)
        
        ws.onClose.whenComplete { _ in
            Task {
                await syncManager.removeClient(ws: ws)
            }
        }
    }
    //TODO: Filter for subsidiary's scope from sessionConfig
    private func getChangedImages(startToken: Int64, endToken: Int64, sessionConfig: SessionConfig, db: any Database) async throws -> [ImageUrl] {
        try await ImageUrl.query(on: db)
            .filter(\.$syncToken > startToken)
            .filter(\.$syncToken <= endToken)
            .all()
    }
    private func getChangedCompany(startToken: Int64, endToken: Int64, sessionConfig: SessionConfig, db: any Database) async throws -> Company? {
        try await Company.query(on: db)
            .filter(\.$syncToken > startToken)
            .filter(\.$syncToken <= endToken)
            .limit(1)
            .all()
            .first
    }
    private func getChangedSubsidiaries(startToken: Int64, endToken: Int64, sessionConfig: SessionConfig, db: any Database) async throws -> [Subsidiary] {
        try await Subsidiary.query(on: db)
            .filter(\.$syncToken > startToken)
            .filter(\.$syncToken <= endToken)
            .all()
    }
    private func getChangedCustomers(startToken: Int64, endToken: Int64, sessionConfig: SessionConfig, db: any Database) async throws -> [Customer] {
        try await Customer.query(on: db)
            .filter(\.$syncToken > startToken)
            .filter(\.$syncToken <= endToken)
            .all()
    }
    private func getChangedEmployees(startToken: Int64, endToken: Int64, sessionConfig: SessionConfig, db: any Database) async throws -> [Employee] {
        try await Employee.query(on: db)
            .filter(\.$syncToken > startToken)
            .filter(\.$syncToken <= endToken)
            .all()
    }
    private func getChangedProducts(startToken: Int64, endToken: Int64, sessionConfig: SessionConfig, db: any Database) async throws -> [Product] {
        try await Product.query(on: db)
            .filter(\.$syncToken > startToken)
            .filter(\.$syncToken <= endToken)
            .all()
    }
    private func getChangedSales(startToken: Int64, endToken: Int64, sessionConfig: SessionConfig, db: any Database) async throws -> [Sale] {
        try await Sale.query(on: db)
            .filter(\.$syncToken > startToken)
            .filter(\.$syncToken <= endToken)
            .all()
    }
    private func getChangedSalesDetail(startToken: Int64, endToken: Int64, sessionConfig: SessionConfig, db: any Database) async throws -> [SaleDetail] {
        try await SaleDetail.query(on: db)
            .filter(\.$syncToken > startToken)
            .filter(\.$syncToken <= endToken)
            .all()
    }
}
