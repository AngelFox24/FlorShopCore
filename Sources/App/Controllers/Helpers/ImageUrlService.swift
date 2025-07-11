//
//  File.swift
//  FlorApiRest
//
//  Created by Angel Curi Laurente on 29/06/2025.
//
import Vapor
import Fluent

struct ImageUrlService {    
    func save(req: Request, imageUrlDto: ImageURLDTO?) async throws -> UUID? {
        guard let imageUrlDto = imageUrlDto else {
            return nil
        }
        //No se permite edicion de ImagenUrl, en todo caso crear uno nuevo
        if let imageUrl = try await ImageUrl.find(imageUrlDto.id, on: req.db) {
            return imageUrl.id
        } else if let imageData = imageUrlDto.imageData { //Si hay imageData entonces guardara imagen local
            guard imageUrlDto.imageHash != "" else {
                throw Abort(.badRequest, reason: "Se debe proporcionar el hash")
            }
            if let imageUrl = try await getImageUrlByHash(hash: imageUrlDto.imageHash, req: req) {
                print("1: Se encontro por Hash")
                return imageUrl.id
            } else if imageUrlDto.imageUrl != "", let imageUrl = try await getImageUrlByUrl(url: imageUrlDto.imageUrl, req: req) {
                print("1: Se encontro por Url")
                return imageUrl.id
            } else {
                print("1: Se Creara que mrd")
                //Create
                let imageUrlNew = ImageUrl(
                    id: imageUrlDto.id,
                    imageUrl: getDomainUrl() + "imageUrls/" + imageUrlDto.id.uuidString,
                    imageHash: imageUrlDto.imageHash
                )
                print("Id de la imagen creada: \(String(describing: imageUrlNew.id))")
                //Crear nueva ImagenUrl
                if !fileExists(id: imageUrlNew.id!) {
                    print("Se guardara en local")
                    //Save imageData in localStorage
                    try createFile(id: imageUrlNew.id!, imageData: imageData)
                    guard fileExists(id: imageUrlNew.id!) else {
                        throw Abort(.badRequest, reason: "Se verifico que la imagen creada no existe")
                    }
                }
                try await imageUrlNew.save(on: req.db)
//                await syncManager.updateLastSyncDate(to: [.image])
                return imageUrlNew.id
            }
        } else if imageUrlDto.imageUrl != "" { //Si no hay imageData debe tener URL
            guard imageUrlDto.imageUrl != "" else {
                throw Abort(.badRequest, reason: "Se debe proporcionar el la url")
            }
            if let imageUrl = try await ImageUrl.find(imageUrlDto.id, on: req.db) {//No actualizamos nada si busca por id
                print("2: Se encontro por Id")
                return imageUrl.id
            } else if imageUrlDto.imageHash != "", let imageUrl = try await getImageUrlByHash(hash: imageUrlDto.imageHash, req: req) {
                print("2: Se encontro por hash")
                return imageUrl.id
            } else if let imageUrl = try await getImageUrlByUrl(url: imageUrlDto.imageUrl, req: req) {
                print("2: Se encontro por Url")
                return imageUrl.id
            } else {
                print("2: Se creara")
                //Create
                let imageUrlNew = imageUrlDto.toImageUrl()
                try await imageUrlNew.save(on: req.db)
//                await syncManager.updateLastSyncDate(to: [.image])
                return imageUrlNew.id
            }
        } else {
            throw Abort(.badRequest, reason: "Se debe proporcionar el ImageData con hash o Url")
        }
    }

    // MARK: - Métodos privados

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
    private func createFile(id: UUID, imageData: Data) throws {
        // Crear el directorio si no existe
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: getImageFolderPath(), withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error al crear el directorio de imágenes: \(error)")
            throw Abort(.badRequest, reason: "Error al crear el directorio de imágenes: \(error)")
        }
        // Escribir los datos de la imagen en el archivo
        fileManager.createFile(atPath: getPathById(id: id), contents: imageData, attributes: nil)
    }
    private func getImageUrlByHash(hash: String, req: Request) async throws -> ImageUrl? {
        return try await ImageUrl.query(on: req.db)
            .filter(\.$imageHash == hash)
            .first()
    }
    private func getImageUrlByUrl(url: String, req: Request) async throws -> ImageUrl? {
        return try await ImageUrl.query(on: req.db)
            .filter(\.$imageUrl == url)
            .first()
    }
}
