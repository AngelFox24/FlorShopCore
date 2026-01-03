import Fluent
import FlorShopDTOs
import Vapor

enum SaleError: Error {
    case alreadyExist
}

// Implementa el protocolo AbortError para proporcionar más información sobre el error
extension SaleError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .alreadyExist:
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .alreadyExist:
            return "Ya hay una venta con el mismo ID"
        }
    }
}

enum SaleDetailError: Error {
    case alreadyExist
}

// Implementa el protocolo AbortError para proporcionar más información sobre el error
extension SaleDetailError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .alreadyExist:
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .alreadyExist:
            return "Ya hay una detalle de venta con el mismo ID"
        }
    }
}

struct SaleController: RouteCollection {
    let syncManager: SyncManager
    let validator: FlorShopAuthValitator
    func boot(routes: any RoutesBuilder) throws {
        let sales = routes.grouped("sales")
        sales.post(use: self.save)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el scoped token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        let saleTransactionDTO = try req.content.decode(RegisterSaleParameters.self)
        let date: Date = Date()
        guard !saleTransactionDTO.cart.cartDetails.isEmpty else {
            print("No se encontro productos en la solicitud de venta")
            throw Abort(.badRequest, reason: "No se encontro productos en la solicitud de venta")
        }
        guard let subsidiaryId = try await Subsidiary.findSubsidiary(subsidiaryCic: payload.subsidiaryCic, on: req.db)?.id else {
            throw Abort(.badRequest, reason: "La subsidiaria no existe")
        }
        guard let employeeSubsidiaryId = try await EmployeeSubsidiary.findEmployeeSubsidiary(
            employeeCic: payload.sub.value,
            subsisiaryCic: payload.subsidiaryCic,
            on: req.db
        )?.id else {
            throw Abort(.badRequest, reason: "El empleado no existe para esta sucursal.")
        }
        let oldGlobalToken: Int64 = await self.syncManager.getLastGlobalToken()
        let oldBranchToken: Int64 = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        //Agregamos detalles a la venta
        let responseString = try await req.db.transaction { transaction -> String in
            guard let subsidiaryEntity = try await Subsidiary.findSubsidiary(subsidiaryCic: payload.subsidiaryCic, on: transaction) else {
                throw Abort(.badRequest, reason: "La subsidiaria no existe")
            }
            let customerEntity: Customer?
            if let customerCic = saleTransactionDTO.customerCic {
                guard let customer = try await Customer.findCustomer(customerCic: customerCic, on: transaction) else {
                    throw Abort(.badRequest, reason: "El cliente no existe")
                }
                customerEntity = customer
            } else {
                customerEntity = nil
            }
            let saleId = UUID()
            let saleNew = Sale(
                id: saleId,
                paymentType: saleTransactionDTO.paymentType,
                saleDate: date,
                total: saleTransactionDTO.cart.total,
                syncToken: await syncManager.nextBranchToken(subsidiaryCic: subsidiaryEntity.subsidiaryCic),
                subsidiaryID: subsidiaryId,
                employeeSubsidiaryID: employeeSubsidiaryId,
                customerID: customerEntity?.id
            )
            try await saleNew.save(on: transaction)
            var totalOwn = 0
            for cartDetailDTO in saleTransactionDTO.cart.cartDetails {
                let productSubsidiary = try await reduceStock(cartDetailDTO: cartDetailDTO, subsidiaryCic: subsidiaryEntity.subsidiaryCic, db: transaction)
                let saleDetailNew = SaleDetail(
                    id: UUID(),
                    productName: productSubsidiary.product.productName,
                    barCode: productSubsidiary.product.barCode,
                    quantitySold: cartDetailDTO.quantity,
                    subtotal: cartDetailDTO.subtotal,
                    unitType: productSubsidiary.product.unitType,
                    unitCost: productSubsidiary.unitCost,
                    unitPrice: productSubsidiary.unitPrice,
                    syncToken: await syncManager.nextBranchToken(subsidiaryCic: subsidiaryEntity.subsidiaryCic),
                    imageUrl: productSubsidiary.product.imageUrl,
                    saleID: saleId
                )
                try await saleDetailNew.save(on: transaction)
                totalOwn += cartDetailDTO.quantity * productSubsidiary.unitPrice
            }
            guard totalOwn == saleTransactionDTO.cart.total else {
                print("Monto no coincide con el calculo de la BD, calculo real: \(totalOwn) calculo enviado: \(saleTransactionDTO.cart.total)")
                throw Abort(.badRequest, reason: "Monto no coincide con el calculo de la BD, calculo real: \(totalOwn) calculo enviado: \(saleTransactionDTO.cart.total)")
            }
            if let customer = customerEntity {
                customer.lastDatePurchase = date
                if customer.totalDebt == 0 {
                    var calendario = Calendar.current
                    calendario.timeZone = TimeZone(identifier: "UTC")!
                    customer.dateLimit = calendario.date(byAdding: .day, value: customer.creditDays, to: date)!
                }
                if saleTransactionDTO.paymentType == .loan {
                    customer.firstDatePurchaseWithCredit = customer.totalDebt == 0 ? date : customer.firstDatePurchaseWithCredit
                    customer.totalDebt = customer.totalDebt + saleTransactionDTO.cart.total
                    if customer.totalDebt > customer.creditLimit && customer.isCreditLimitActive {
                        customer.isCreditLimit = true
                    } else {
                        customer.isCreditLimit = false
                    }
                }
                customer.syncToken = await self.syncManager.nextGlobalToken()
                try await customer.update(on: transaction)
            }
            return ("Venta Exitosa")
        }
        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return DefaultResponse(message: responseString)
    }
//    private func correctAmount(saleTransactionDTO: SaleTransactionDTO, db: any Database) async throws -> Bool {
//        let cartDTO = saleTransactionDTO.cart
//        for cartDetailDTO in cartDTO.cartDetails {
//            
//        }
//    }
    private func reduceStock(cartDetailDTO: CartDetailServerDTO, subsidiaryCic: String, db: any Database) async throws -> ProductSubsidiary {
        guard let productSubsidiaryEntity = try await ProductSubsidiary.findProductSubsidiary(
            productCic: cartDetailDTO.productCic,
            subsisiaryCic: subsidiaryCic,
            on: db
        ) else {
            throw Abort(.internalServerError, reason: "No se encontro este producto en la subsidiaria")
        }
        if productSubsidiaryEntity.quantityStock >= cartDetailDTO.quantity {
            productSubsidiaryEntity.quantityStock -= cartDetailDTO.quantity
            productSubsidiaryEntity.syncToken = await syncManager.nextBranchToken(subsidiaryCic: subsidiaryCic)
            try await productSubsidiaryEntity.update(on: db)
            return productSubsidiaryEntity
        } else {
            print("No hay stock suficiente")
            throw Abort(.badRequest, reason: "No hay stock suficiente")
        }
    }
}
