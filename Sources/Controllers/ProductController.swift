import Fluent
import FlorShop_DTOs
import Vapor

struct ProductController: RouteCollection {
    let syncManager: SyncManager
    let imageUrlService: ImageUrlService
    func boot(routes: any RoutesBuilder) throws {
        let products = routes.grouped("products")
        products.post(use: self.save)
//        products.post("bulkCreate", use: self.bulkCreate)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        let productDTO = try req.content.decode(ProductServerDTO.self)
        guard productDTO.productName != "" else {
            throw Abort(.badRequest, reason: "El nombre del producto no puede ser vacio")
        }
        let responseString: String = try await req.db.transaction { transaction -> String in
            let imageId = try await imageUrlService.save(
                db: transaction,
                imageUrlServerDto: productDTO.imageUrl,
                syncToken: syncManager.nextToken()
            )
            if let product = try await Product.find(productDTO.id, on: transaction) {
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
                product.active = productDTO.active
                product.expirationDate = productDTO.expirationDate
                product.quantityStock = productDTO.quantityStock
                product.unitType = productDTO.unitType
                product.unitCost = productDTO.unitCost
                product.unitPrice = productDTO.unitPrice
                product.syncToken = await syncManager.nextToken()
                product.$imageUrl.id = imageId
                try await product.update(on: transaction)
                return ("Updated")
            } else {
                guard let subsidiaryId = try await Subsidiary.find(productDTO.subsidiaryId, on: transaction)?.id else {
                    throw Abort(.badRequest, reason: "La subsidiaria no existe")
                }
                guard try await !productNameExist(productDTO: productDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre del producto ya existe")
                }
                guard try await !productBarCodeExist(productDTO: productDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El codigo de barras del producto ya existe")
                }
                //Create
                let productNew = Product(
                    id: UUID(),
                    productName: productDTO.productName,
                    barCode: productDTO.barCode,
                    active: productDTO.active,
                    expirationDate: productDTO.expirationDate,
                    unitType: productDTO.unitType,
                    quantityStock: productDTO.quantityStock,
                    unitCost: productDTO.unitCost,
                    unitPrice: productDTO.unitPrice,
                    syncToken: await syncManager.nextToken(),
                    subsidiaryID: subsidiaryId,
                    imageUrlID: imageId
                )
                try await productNew.save(on: transaction)
                return ("Created")
            }
        }
        await self.syncManager.sendSyncData()
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
