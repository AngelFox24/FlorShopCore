import Fluent
import Vapor

struct CustomerContoller: RouteCollection {
    let syncManager: SyncManager
    let imageUrlService: ImageUrlService
    func boot(routes: any RoutesBuilder) throws {
        let customers = routes.grouped("customers")
        customers.post(use: self.save)
        customers.post("payDebt", use: self.payDebt)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        let customerDTO = try req.content.decode(CustomerInputDTO.self)
        let responseString: String = try await req.db.transaction { transaction -> String in
            let imageId = try await imageUrlService.save(
                db: transaction,
                imageUrlInputDto: customerDTO.imageUrl,
                syncToken: syncManager.nextToken()
            )
            if let customer = try await Customer.find(customerDTO.id, on: transaction) {
                //Update
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
                customer.syncToken = await syncManager.nextToken()
                customer.$imageUrl.id = imageId
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
                guard let companyID = try await Company.find(customerDTO.companyID, on: transaction)?.id else {
                    throw Abort(.badRequest, reason: "La compañia no existe")
                }
                guard try await !customerFullNameExist(customerDTO: customerDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre y apellido del cliente ya existe")
                }
                let customerNew = Customer(
                    id: customerDTO.id,
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
                    syncToken: await syncManager.nextToken(),
                    companyID: companyID,
                    imageUrlID: imageId
                )
                try await customerNew.save(on: transaction)
                return ("Created")
            }
        }
        await self.syncManager.sendSyncData()
        return DefaultResponse(message: responseString)
    }
    @Sendable
    func payDebt(req: Request) async throws -> PayCustomerDebtResponse {
        let payCustomerDebtParameters = try req.content.decode(PayCustomerDebtParameters.self)
        guard let customer = try await Customer.find(payCustomerDebtParameters.customerId, on: req.db) else {
            throw Abort(.badRequest, reason: "El cliente no existe")
        }
        guard payCustomerDebtParameters.amount > 0 else {
            throw Abort(.badRequest, reason: "El monto debe ser mayor a 0")
        }
        let remainingMoney = try await req.db.transaction { transaction -> Int in
            var customerTotalDebt = customer.totalDebt
            var remainingMoney = payCustomerDebtParameters.amount
            let sales = try await getSalesWithDebt(customerId: payCustomerDebtParameters.customerId, db: transaction)
            for sale in sales {
                let subtotal = sale.toSaleDetail.reduce(0) {$0 + ($1.unitPrice * $1.quantitySold)}
                if remainingMoney >= subtotal && customerTotalDebt >= subtotal  { //Si alcanza para pagar esta deuda y deuda del cliente debe ser mayor a subtotal
                    remainingMoney -= subtotal
                    sale.paymentType = PaymentType.cash.description
                    customerTotalDebt -= subtotal
                    try await sale.update(on: transaction)
                }
            }
            customer.totalDebt = customerTotalDebt
            customer.isCreditLimit = customer.isCreditLimitActive ? customer.totalDebt > customer.creditLimit : false
            customer.isDateLimit = customer.isDateLimitActive ? Date() > customer.dateLimit : false
            try await customer.update(on: transaction)
            return remainingMoney
        }
        await syncManager.sendSyncData()
        return PayCustomerDebtResponse(
            customerId: payCustomerDebtParameters.customerId,
            change: remainingMoney
        )
    }
    //TODO: Optimize this with pagination
    private func getSalesWithDebt(customerId: UUID, db: any Database) async throws -> [Sale] {
        return try await Sale.query(on: db)
            .filter(\.$customer.$id == customerId)
            .filter(\.$paymentType == PaymentType.loan.description)
            .with(\.$toSaleDetail)
            .sort(\.$createdAt, .ascending)
            .all()
    }
    private func customerFullNameExist(customerDTO: CustomerInputDTO, db: any Database) async throws -> Bool {
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
