import Fluent
import FlorShopDTOs
import Vapor

struct ProductController: RouteCollection {
    let syncManager: SyncManager
    let validator: FlorShopAuthValitator
    func boot(routes: any RoutesBuilder) throws {
        let products = routes.grouped("products")
        products.post(use: self.save)
//        products.post("bulkCreate", use: self.bulkCreate)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Manda el scoped token mrda")
        }
        let payload = try await validator.verifyToken(token, client: req.client)
        let productDTO = try req.content.decode(ProductServerDTO.self)
        guard productDTO.productName != "" else {
            throw Abort(.badRequest, reason: "El nombre del producto no puede ser vacio")
        }
        let oldGlobalToken: Int64 = await self.syncManager.getLastGlobalToken()
        let oldBranchToken: Int64 = await self.syncManager.getLastBranchToken(subsidiaryCic: payload.subsidiaryCic)
        let responseString: String = try await req.db.transaction { transaction -> String in
            guard let subsidiaryEntity = try await Subsidiary.findSubsidiary(subsidiaryCic: payload.subsidiaryCic, on: transaction),
                  let subsidiaryId = subsidiaryEntity.id else {
                throw Abort(.badRequest, reason: "La subsidiaria no existe")
            }
            if let product = try await Product.findProduct(productCic: productDTO.productCic, on: transaction) {
                var result = "Don't updated"
                if !productDTO.isMainEqual(to: product) {
                    //Update
                    if product.productName != productDTO.productName {
                        guard try await !productNameExist(productDTO: productDTO, db: transaction) else {
                            throw Abort(.badRequest, reason: "El nombre del producto ya existe")
                        }
                        product.productName = productDTO.productName
                    }
                    if product.barCode != productDTO.barCode {
                        guard try await !productBarCodeExist(productDTO: productDTO, db: transaction) else {
                            throw Abort(.badRequest, reason: "El codigo de barras del producto ya existe")
                        }
                        product.barCode = productDTO.barCode
                    }
                    product.unitType = productDTO.unitType
                    product.imageUrl = productDTO.imageUrl
                    product.syncToken = await syncManager.nextGlobalToken()
                    try await product.update(on: transaction)
                    result = "Updated"
                }
                guard let productSubsidiary = try await ProductSubsidiary.findProductSubsidiary(
                    productCic: product.productCic,
                    subsisiaryCic: payload.subsidiaryCic,
                    on: transaction
                ) else {
                    throw Abort(.badRequest, reason: "ProductSubsidiary no existe")
                }
                if !productDTO.isChildEqual(to: productSubsidiary) {
                    productSubsidiary.active = productDTO.active
                    productSubsidiary.expirationDate = productDTO.expirationDate
                    productSubsidiary.quantityStock = productDTO.quantityStock
                    productSubsidiary.unitCost = productDTO.unitCost
                    productSubsidiary.unitPrice = productDTO.unitPrice
                    productSubsidiary.syncToken = await syncManager.nextBranchToken(subsidiaryCic: subsidiaryEntity.subsidiaryCic)
                    try await productSubsidiary.update(on: transaction)
                    result = "Updated"
                }
                return result
            } else {
                guard let companyId = try await Company.findCompany(companyCic: payload.companyCic, on: transaction)?.id else {
                    throw Abort(.badRequest, reason: "La compañia no existe")
                }
                guard try await !productNameExist(productDTO: productDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre del producto ya existe")
                }
                guard try await !productBarCodeExist(productDTO: productDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El codigo de barras del producto ya existe")
                }
                //Create
                let productNew = Product(
                    productCic: UUID().uuidString,
                    barCode: productDTO.barCode,
                    productName: productDTO.productName,
                    unitType: productDTO.unitType,
                    syncToken: await syncManager.nextGlobalToken(),
                    imageUrl: productDTO.imageUrl,
                    companyID: companyId
                )
                try await productNew.save(on: transaction)
                guard let productId = productNew.id else {
                    throw Abort(.internalServerError, reason: "Product id no encontrado")
                }
                let newProductSubsidiary = ProductSubsidiary(
                    active: productDTO.active,
                    expirationDate: productDTO.expirationDate,
                    quantityStock: productDTO.quantityStock,
                    unitCost: productDTO.unitCost,
                    unitPrice: productDTO.unitPrice,
                    syncToken: await syncManager.nextBranchToken(subsidiaryCic: subsidiaryEntity.subsidiaryCic),
                    productID: productId,
                    subsidiaryID: subsidiaryId
                )
                try await newProductSubsidiary.save(on: transaction)
                return ("Created")
            }
        }
        await self.syncManager.sendSyncData(oldGlobalToken: oldGlobalToken, oldBranchToken: oldBranchToken, subsidiaryCic: payload.subsidiaryCic)
        return DefaultResponse(message: responseString)
    }
    private func productNameExist(productDTO: ProductServerDTO, db: any Database) async throws -> Bool {
        guard productDTO.productName != "" else {
            print("Producto existe vacio aunque no exista xd")
            return true
        }
        let query = try await Product.query(on: db)
            .filter(\.$productName == productDTO.productName)
            .limit(1)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
    private func productBarCodeExist(productDTO: ProductServerDTO, db: any Database) async throws -> Bool {
        guard productDTO.barCode != "" else {
            print("Producto barcode vacio aunque no exista xd")
            return false
        }
        let query = try await Product.query(on: db)
            .filter(\.$barCode == productDTO.barCode)
            .limit(1)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
//    @Sendable
//    func bulkCreate(req: Request) async throws -> DefaultResponse {
//        //No controla elementos repetidos osea Update
//        let productsDTO = try req.content.decode([ProductServerDTO].self)
//
//        // Iniciar la transacción
//        return try await req.db.transaction { transaction in
//            // Iterar sobre cada producto y guardarlo
//            for productDTO in productsDTO {
//                let _ = productDTO.imageUrl
////                if let imageUrl = imageUrlDTO?.toImageUrl() {
////                    try await imageUrl.save(on: transaction)
////                }
//                let product = productDTO.toProduct()
//                try await product.save(on: transaction)
//            }
//            return DefaultResponse(message: "Created")
//        }
//    }
}
