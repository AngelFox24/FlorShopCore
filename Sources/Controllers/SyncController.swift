import Fluent
import Vapor
import FlorShopDTOs

struct SyncController: RouteCollection {
    let syncManager: SyncManager
    let syncLimit: Int = 50
    let validator: FlorShopAuthValitator
    func boot(routes: any RoutesBuilder) throws {
        let subsidiaries = routes.grouped("sync")
        subsidiaries.post(use: self.sync)
        subsidiaries.webSocket("ws", onUpgrade: self.handleWebSocket)
    }
    @Sendable
    func sync(req: Request) async throws -> SyncResponse {
        print("Api version 2.0")
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        let request = try req.content.decode(SyncRequest.self)
        //        let syncOutputParameters: SyncResponse = try await req.db.transaction { transaction in
        let clientGlobalToken = request.globalSyncToken
        let clientBranchToken = request.branchSyncToken
        let serverGlobalToken = await self.syncManager.getLastGlobalToken()
        let serverBranchToken = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        
        let fetchGlobalEntities: Bool = clientGlobalToken < serverGlobalToken
        let fetchBranchEntities: Bool = clientBranchToken < serverBranchToken
        
        let globalTokenLimit = min(clientGlobalToken + Int64(syncLimit), serverGlobalToken)
        let branchTokenLimit = min(clientBranchToken + Int64(syncLimit), serverBranchToken)
        //            print("[SyncController] New Request, startToken: \(clientToken), endToken: \(tokenLimit)")
        //MARK: Global Sync
        let syncGlobalFetchParam = GlobalSyncFetchParams(startToken: clientGlobalToken, endToken: globalTokenLimit)
        async let company = fetchGlobalEntities ? self.getChangedCompany(syncFetchParam: syncGlobalFetchParam, db: req.db) : nil
        async let employees = fetchBranchEntities ? self.getChangedEmployees(syncFetchParam: syncGlobalFetchParam, db: req.db) : []
        async let subsidiaries = fetchGlobalEntities ? self.getChangedSubsidiaries(syncFetchParam: syncGlobalFetchParam, db: req.db) : []
        async let customers = fetchGlobalEntities ? self.getChangedCustomers(syncFetchParam: syncGlobalFetchParam, db: req.db) : []
        async let products = fetchGlobalEntities ? self.getChangedProducts(syncFetchParam: syncGlobalFetchParam, db: req.db) : []
        //MARK: Branch Sync
        let syncBranchFetchParam = BranchSyncFetchParams(startToken: clientBranchToken, endToken: branchTokenLimit, subsidiaryCic: payload.subsidiaryCic)
        async let employeesSubsidiary = fetchBranchEntities ? self.getChangedEmployeesSubsidiary(syncFetchParam: syncBranchFetchParam, db: req.db) : []
        async let productsSubsidiary = fetchBranchEntities ? self.getChangedProductsSubsidiary(syncFetchParam: syncBranchFetchParam, db: req.db) : []
        async let sales = fetchBranchEntities ? self.getChangedSales(syncFetchParam: syncBranchFetchParam, db: req.db) : []
        async let salesDetail = fetchBranchEntities ? self.getChangedSalesDetail(syncFetchParam: syncBranchFetchParam, db: req.db) : []
        // Esperar todos en paralelo
        let sync = SyncResponse(
            company: try await company?.toCompanyDTO(),
            //Company puede ser nulo, casi siempre no se actualiza
            subsidiaries: try await subsidiaries.mapToListSubsidiaryDTO(),
            employees: try await employees.mapToListEmployeeDTO(),
            employeesSubsidiary: try await employeesSubsidiary.mapToListEmployeeSubsidiaryDTO(),
            customers: try await customers.mapToListCustomerDTO(),
            products: try await products.mapToListProductDTO(),
            productsSubsidiary: try await productsSubsidiary.mapToListProductSubsidiaryDTO(),
            sales: try await sales.mapToListSaleDTO(),
            salesDetail: try await salesDetail.mapToListSaleDetailDTO(),
            lastGlobalToken: globalTokenLimit,
            isGlobalUpToDate: globalTokenLimit == serverGlobalToken,
            lastBranchToken: branchTokenLimit,
            isBranchUpToDate: branchTokenLimit == serverBranchToken
        )
        //        }
        return sync
    }
    @Sendable
    func handleWebSocket(req: Request, ws: WebSocket) async {
        guard let token = req.headers.bearerAuthorization?.token else {
            print("[SyncController] WebSocket desconectado porque no tiene token")
            ws.close(promise: nil)
            return
        }
        do {
            let payload = try await validator.verifyToken(token, client: req.client)
            try await syncManager.addClient(ws: ws, subsidiaryCic: payload.subsidiaryCic, employeeCic: payload.sub.value)
        } catch {
            // Token no valido → cerrar
            print("[SyncController] WebSocket desconectado porque el token es invalido")
            ws.close(promise: nil)
            return
        }
        // Establece un intervalo de ping
        ws.pingInterval = .seconds(10)
        
        ws.onClose.whenComplete { _ in
            Task {
                print("[SyncController] WebSocket desconectado por inactividad")
                await syncManager.removeClient(ws: ws)
            }
        }
    }
    //MARK: Fetch Global Tables
    private func getChangedCompany(syncFetchParam: GlobalSyncFetchParams, db: any Database) async throws -> Company? {
        try await Company.query(on: db)
            .filter(Company.self, \.$syncToken > syncFetchParam.startToken)
            .filter(Company.self, \.$syncToken <= syncFetchParam.endToken)
            .limit(1)
            .first()
    }
    private func getChangedSubsidiaries(syncFetchParam: GlobalSyncFetchParams, db: any Database) async throws -> [Subsidiary] {
        try await Subsidiary.query(on: db)
            .filter(Subsidiary.self, \.$syncToken > syncFetchParam.startToken)
            .filter(Subsidiary.self, \.$syncToken <= syncFetchParam.endToken)
            .with(\.$company)
            .all()
    }
    private func getChangedEmployees(syncFetchParam: GlobalSyncFetchParams, db: any Database) async throws -> [Employee] {
        try await Employee.query(on: db)
            .filter(Employee.self, \.$syncToken > syncFetchParam.startToken)
            .filter(Employee.self, \.$syncToken <= syncFetchParam.endToken)
            .with(\.$company)
            .all()
    }
    private func getChangedCustomers(syncFetchParam: GlobalSyncFetchParams, db: any Database) async throws -> [Customer] {
        try await Customer.query(on: db)
            .filter(Customer.self, \.$syncToken > syncFetchParam.startToken)
            .filter(Customer.self, \.$syncToken <= syncFetchParam.endToken)
            .all()
    }
    private func getChangedProducts(syncFetchParam: GlobalSyncFetchParams, db: any Database) async throws -> [Product] {
        try await Product.query(on: db)
            .filter(Product.self, \.$syncToken > syncFetchParam.startToken)
            .filter(Product.self, \.$syncToken <= syncFetchParam.endToken)
            .with(\.$company)
            .all()
    }
    //MARK: Fetch Branch Tables
    private func getChangedEmployeesSubsidiary(syncFetchParam: BranchSyncFetchParams, db: any Database) async throws -> [EmployeeSubsidiary] {
        try await EmployeeSubsidiary.query(on: db)
            .join(Subsidiary.self, on: \Subsidiary.$id == \EmployeeSubsidiary.$subsidiary.$id)
            .filter(Subsidiary.self, \.$subsidiaryCic == syncFetchParam.subsidiaryCic)
            .filter(EmployeeSubsidiary.self, \.$syncToken > syncFetchParam.startToken)
            .filter(EmployeeSubsidiary.self, \.$syncToken <= syncFetchParam.endToken)
            .with(\.$subsidiary)
            .with(\.$employee)
            .all()
    }
    private func getChangedProductsSubsidiary(syncFetchParam: BranchSyncFetchParams, db: any Database) async throws -> [ProductSubsidiary] {
        try await ProductSubsidiary.query(on: db)
            .join(Subsidiary.self, on: \Subsidiary.$id == \ProductSubsidiary.$subsidiary.$id)
            .filter(Subsidiary.self, \.$subsidiaryCic == syncFetchParam.subsidiaryCic)
            .filter(ProductSubsidiary.self, \.$syncToken > syncFetchParam.startToken)
            .filter(ProductSubsidiary.self, \.$syncToken <= syncFetchParam.endToken)
            .with(\.$subsidiary)
            .with(\.$product)
            .all()
    }
    private func getChangedSales(syncFetchParam: BranchSyncFetchParams, db: any Database) async throws -> [Sale] {
        try await Sale.query(on: db)
            .join(Subsidiary.self, on: \Subsidiary.$id == \Sale.$subsidiary.$id)
            .filter(Subsidiary.self, \.$subsidiaryCic == syncFetchParam.subsidiaryCic)
            .filter(Sale.self, \.$syncToken > syncFetchParam.startToken)
            .filter(Sale.self, \.$syncToken <= syncFetchParam.endToken)
            .with(\.$subsidiary)
            .all()
    }
    private func getChangedSalesDetail(syncFetchParam: BranchSyncFetchParams, db: any Database) async throws -> [SaleDetail] {
        try await SaleDetail.query(on: db)
            .join(Sale.self, on: \Sale.$id == \SaleDetail.$sale.$id)
            .join(Subsidiary.self, on: \Subsidiary.$id == \Sale.$subsidiary.$id)
            .filter(Subsidiary.self, \.$subsidiaryCic == syncFetchParam.subsidiaryCic)
            .filter(SaleDetail.self, \.$syncToken > syncFetchParam.startToken)
            .filter(SaleDetail.self, \.$syncToken <= syncFetchParam.endToken)
            .with(\.$sale)
            .all()
    }
}

struct GlobalSyncFetchParams {
    let startToken: Int64
    let endToken: Int64
}

struct BranchSyncFetchParams {
    let startToken: Int64
    let endToken: Int64
    let subsidiaryCic: String
}
