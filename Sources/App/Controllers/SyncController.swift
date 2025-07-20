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
    func sync(req: Request) async throws -> SyncOutputParameters {
        print("Api version 2.0")
        let request = try req.content.decode(SyncInputParameters.self)
        let lastToken = await syncManager.getLastSyncToken()
        guard request.syncToken > lastToken else {
            return SyncOutputParameters.empty()
        }
        let syncOutputParameters: SyncOutputParameters = try await req.db.transaction { transaction in
            async let images = self.getChangedImages(since: request.syncToken, db: transaction)
            async let company = self.getChangedCompany(since: request.syncToken, db: transaction)
            async let subsidiaries = self.getChangedSubsidiaries(since: request.syncToken, db: transaction)
            async let employees = self.getChangedEmployees(since: request.syncToken, db: transaction)
            async let customers = self.getChangedCustomers(since: request.syncToken, db: transaction)
            async let products = self.getChangedProducts(since: request.syncToken, db: transaction)
            async let sales = self.getChangedSales(since: request.syncToken, db: transaction)
            async let salesDetail = self.getChangedSalesDetail(since: request.syncToken, db: transaction)

            // Esperar todos en paralelo
            return SyncOutputParameters(
                images: try await images.mapToListImageURLDTO(),
                company: try await company?.toCompanyDTO(),//Company puede ser nulo, casi siempre no se actualiza
                subsidiaries: try await subsidiaries.mapToListSubsidiaryDTO(),
                employees: try await employees.mapToListEmployeeDTO(),
                customers: try await customers.mapToListCustomerDTO(),
                products: try await products.mapToListProductDTO(),
                sales: try await sales.mapToListSaleDTO(),
                salesDetail: try await salesDetail.mapToListSaleDetailDTO(),
                isUpToDate: request.syncToken + Int64(syncLimit) >= lastToken
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
    func getChangedImages(since: Int64, db: any Database) async throws -> [ImageUrl] {
        try await ImageUrl.query(on: db)
            .filter(\.$syncToken > since)
            .filter(\.$syncToken <= since + Int64(syncLimit))
            .limit(syncLimit)
            .all()
    }
    func getChangedCompany(since: Int64, db: any Database) async throws -> Company? {
        guard let company = try await Company.query(on: db)
            .filter(\.$syncToken > since)
            .filter(\.$syncToken <= since + Int64(syncLimit))
            .limit(1)
            .all()
            .first
        else {
            throw Abort(.badRequest, reason: "No existe compania en la BD")
        }
        return company
    }
    func getChangedSubsidiaries(since: Int64, db: any Database) async throws -> [Subsidiary] {
        try await Subsidiary.query(on: db)
            .filter(\.$syncToken > since)
            .filter(\.$syncToken <= since + Int64(syncLimit))
            .limit(syncLimit)
            .all()
    }
    func getChangedCustomers(since: Int64, db: any Database) async throws -> [Customer] {
        try await Customer.query(on: db)
            .filter(\.$syncToken > since)
            .filter(\.$syncToken <= since + Int64(syncLimit))
            .limit(syncLimit)
            .all()
    }
    func getChangedEmployees(since: Int64, db: any Database) async throws -> [Employee] {
        try await Employee.query(on: db)
            .filter(\.$syncToken > since)
            .filter(\.$syncToken <= since + Int64(syncLimit))
            .limit(syncLimit)
            .all()
    }
    func getChangedProducts(since: Int64, db: any Database) async throws -> [Product] {
        try await Product.query(on: db)
            .filter(\.$syncToken > since)
            .filter(\.$syncToken <= since + Int64(syncLimit))
            .limit(syncLimit)
            .all()
    }
    func getChangedSales(since: Int64, db: any Database) async throws -> [Sale] {
        try await Sale.query(on: db)
            .filter(\.$syncToken > since)
            .filter(\.$syncToken <= since + Int64(syncLimit))
            .limit(syncLimit)
            .all()
    }
    func getChangedSalesDetail(since: Int64, db: any Database) async throws -> [SaleDetail] {
        try await SaleDetail.query(on: db)
            .filter(\.$syncToken > since)
            .filter(\.$syncToken <= since + Int64(syncLimit))
            .limit(syncLimit)
            .all()
    }
}
