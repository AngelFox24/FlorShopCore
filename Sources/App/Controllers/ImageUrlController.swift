import Fluent
import Vapor

struct ImageUrlController: RouteCollection {
    let syncManager: SyncManager
    let imageUrlService: ImageUrlService
    func boot(routes: any RoutesBuilder) throws {
        let imageUrl = routes.grouped("imageUrls")
//        imageUrl.post("sync", use: self.sync)
        imageUrl.get(":imageId", use: self.serveImage)
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
