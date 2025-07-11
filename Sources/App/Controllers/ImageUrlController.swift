import Fluent
import Vapor

struct ImageUrlController: RouteCollection {
    let syncManager: SyncManager
    let imageUrlService: ImageUrlService
    func boot(routes: any RoutesBuilder) throws {
        let imageUrl = routes.grouped("imageUrls")
        imageUrl.post("sync", use: self.sync)
        imageUrl.get(":imageId", use: self.serveImage)
    }
    @Sendable
    func sync(req: Request) async throws -> SyncImageUrlResponse {
        let request = try req.content.decode(SyncImageParameters.self)
        guard try await syncManager.shouldSync(clientSyncIds: request.syncIds, entity: .image) else {
            return SyncImageUrlResponse(
                imagesUrlDTOs: [],
                syncIds: request.syncIds
            )
        }
        let maxPerPage: Int = 50
        let query = ImageUrl.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .limit(maxPerPage)
        let images = try await query.all()
        return await SyncImageUrlResponse(
            imagesUrlDTOs: images.mapToListImageURLDTO(),
            syncIds: images.count == maxPerPage ? request.syncIds : syncManager.getUpdatedSyncTokens(entity: .image, clientTokens: request.syncIds)
        )
    }
    @Sendable
    func serveImage(req: Request) async throws -> Response {
        // Extraer el UUID de la URL
        guard let imageIdS = req.parameters.get("imageId") else {
            throw Abort(.badRequest, reason: "No image ID provided")
        }
        guard let imageId = UUID(uuidString: imageIdS) else {
            throw Abort(.badRequest, reason: "El id es invalido")
        }
        guard fileExists(id: imageId) else {
            throw Abort(.notFound, reason: "Image not found")
        }
        // Ruta donde se almacenan las imágenes en el servidor
        let imageDirectory: String = getPathById(id: imageId)
        // Crear la respuesta con el contenido de la imagen
        return try await req.fileio.asyncStreamFile(at: imageDirectory)
    }
    private func getPathById(id: UUID) -> String {
        let filename = id.uuidString + ".jpg"
        let filePath = getImageFolderPath() + filename
        return filePath
    }
    private func getImageFolderPath() -> String {
        return "/app/images/"
    }
    private func getDomainUrl() -> String {
        return "https://pizzarely.mrangel.dev/"
    }
    private func fileExists(id: UUID) -> Bool {
        let fileManager = FileManager.default
        let filePath = getImageFolderPath() + id.uuidString + ".jpg"
        let result = fileManager.fileExists(atPath: filePath)
        print("Se esta verificado que exista la imagen: \(result) file: \(filePath)")
        return result
    }
}
