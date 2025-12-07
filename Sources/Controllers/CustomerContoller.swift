import Fluent
import FlorShopDTOs
import Vapor

struct CustomerContoller: RouteCollection {
    let syncManager: SyncManager
    let validator: FlorShopAuthValitator
    func boot(routes: any RoutesBuilder) throws {
        let customers = routes.grouped("customers")
        customers.post(use: self.save)
        customers.post("payDebt", use: self.payDebt)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        let customerDTO = try req.content.decode(CustomerServerDTO.self)
        let oldGlobalToken: Int64 = await self.syncManager.getLastGlobalToken()
        let oldBranchToken: Int64 = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        let responseString: String = try await req.db.transaction { transaction -> String in
            if let customerCic = customerDTO.customerCic {//tiene la intencion de actualizar
                guard let customer = try await Customer.findCustomer(customerCic: customerCic, on: transaction) else {
                    throw Abort(.badRequest, reason: "El cliente no existe para ser actualizado")
                }
                if customer.name != customerDTO.name || customer.lastName != customerDTO.lastName {
                    guard try await !customerFullNameExist(customerDTO: customerDTO, db: transaction) else {
                        throw Abort(.badRequest, reason: "El nombre y apellido del cliente ya existe")
                    }
                    customer.name = customerDTO.name
                    customer.lastName = customerDTO.lastName
                }
                customer.creditDays = customerDTO.creditDays
                customer.creditLimit = customerDTO.creditLimit
                customer.isCreditLimitActive = customerDTO.isCreditLimitActive
                customer.isDateLimitActive = customerDTO.isDateLimitActive
                customer.phoneNumber = customerDTO.phoneNumber
                customer.imageUrl = customerDTO.imageUrl
                customer.syncToken = await syncManager.nextGlobalToken()
                //TODO: Use calculated variables
                if customerDTO.isDateLimitActive && customer.totalDebt > 0,
                   let firstDatePurchaseWithCredit = customer.firstDatePurchaseWithCredit {
                    var calendar = Calendar.current
                    calendar.timeZone = TimeZone(identifier: "UTC")!
                    customer.dateLimit = calendar.date(byAdding: .day, value: customer.creditDays, to: firstDatePurchaseWithCredit)!
                    let finalDelDia = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
                    customer.isDateLimit = customer.dateLimit < finalDelDia
                }
                customer.isCreditLimit = customer.isCreditLimitActive ? customer.totalDebt >= customer.creditLimit : false
                try await customer.update(on: transaction)
                return ("Updated")
            } else {
                //Create
                guard let companyID = try await Company.findCompany(companyCic: payload.companyCic, on: transaction)?.id else {
                    throw Abort(.badRequest, reason: "La compañia no existe")
                }
                guard try await !customerFullNameExist(customerDTO: customerDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre y apellido del cliente ya existe")
                }
                let customerNew = Customer(
                    customerCic: UUID().uuidString,
                    name: customerDTO.name,
                    lastName: customerDTO.lastName,
                    totalDebt: 0,
                    creditScore: 0,
                    creditDays: customerDTO.creditDays,
                    isCreditLimitActive: customerDTO.isCreditLimitActive,
                    isCreditLimit: false,
                    isDateLimitActive: customerDTO.isDateLimitActive,
                    isDateLimit: false,
                    dateLimit: customerDTO.dateLimit,
                    firstDatePurchaseWithCredit: nil,
                    lastDatePurchase: customerDTO.lastDatePurchase,
                    phoneNumber: customerDTO.phoneNumber,
                    creditLimit: customerDTO.creditLimit,
                    imageUrl: customerDTO.imageUrl,
                    syncToken: await syncManager.nextGlobalToken(),
                    companyID: companyID
                )
                try await customerNew.save(on: transaction)
                return ("Created")
            }
        }
        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return DefaultResponse(message: responseString)
    }
    @Sendable
    func payDebt(req: Request) async throws -> PayCustomerDebtClientDTO {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        let payCustomerDebtParameters = try req.content.decode(PayCustomerDebtServerDTO.self)
        guard let customer = try await Customer.findCustomer(customerCic: payload.sub.value, on: req.db) else {
            throw Abort(.badRequest, reason: "El cliente no existe")
        }
        guard payCustomerDebtParameters.amount > 0 else {
            throw Abort(.badRequest, reason: "El monto debe ser mayor a 0")
        }
        let oldGlobalToken: Int64 = await self.syncManager.getLastGlobalToken()
        let oldBranchToken: Int64 = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        let remainingMoney = try await req.db.transaction { transaction -> Int in
            var customerTotalDebt = customer.totalDebt
            var remainingMoney = payCustomerDebtParameters.amount
            let sales = try await getSalesWithDebt(customerCic: payCustomerDebtParameters.customerCic, db: transaction)
            for sale in sales {
                let subtotal = sale.toSaleDetail.reduce(0) {$0 + ($1.unitPrice * $1.quantitySold)}
                if remainingMoney >= subtotal && customerTotalDebt >= subtotal  { //Si alcanza para pagar esta deuda y deuda del cliente debe ser mayor a subtotal
                    remainingMoney -= subtotal
                    sale.paymentType = PaymentType.cash
                    sale.syncToken = await self.syncManager.nextBranchToken(subsidiaryCic: payload.subsidiaryCic)
                    customerTotalDebt -= subtotal
                    try await sale.update(on: transaction)
                }
            }
            customer.totalDebt = customerTotalDebt
            customer.isCreditLimit = customer.isCreditLimitActive ? customer.totalDebt > customer.creditLimit : false
            customer.isDateLimit = customer.isDateLimitActive ? Date() > customer.dateLimit : false
            customer.syncToken = await self.syncManager.nextGlobalToken()
            try await customer.update(on: transaction)
            return remainingMoney
        }
        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return PayCustomerDebtClientDTO(
            customerCic: payCustomerDebtParameters.customerCic,
            change: remainingMoney
        )
    }
    //TODO: Optimize this with pagination
    private func getSalesWithDebt(customerCic: String, db: any Database) async throws -> [Sale] {
        return try await Sale.query(on: db)
            .join(Customer.self, on: \Customer.$id == \Sale.$id)
            .filter(Customer.self ,\.$customerCic == customerCic)
            .filter(Sale.self, \.$paymentType == PaymentType.loan)
            .with(\.$toSaleDetail)
            .sort(\.$createdAt, .ascending)
            .all()
    }
    private func customerFullNameExist(customerDTO: CustomerServerDTO, db: any Database) async throws -> Bool {
        let name = customerDTO.name
        let lastName = customerDTO.lastName
        let query = try await Customer.query(on: db)
            .filter(\.$name == name)
            .filter(\.$lastName == lastName)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
}
