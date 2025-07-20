//
//  File.swift
//  FlorApiRest
//
//  Created by Angel Curi Laurente on 29/06/2025.
import Vapor
import Fluent
import FlorShop_DTOs

enum TypeOfCreation {
    case createByURL(url: String, hash: String)
    case createByData(data: Data, hash: String)
}

struct ImageUrlService {
    
    ///Metodos para asignar una imagen
    ///1: (Para imagenes que ya existen en BD)
    ///- Se envia el Id
    ///- Los demas campos pueden estar vacios
    ///
    ///Metodos para guardar una imagen
    ///1: (Para imagenes de internet que solo tienen URL)
    ///- No hay Id (se supone que es nuevo)
    ///- Se envia la URL
    ///- El Hash debe estar vacio
    ///- El image data debe estar vacio
    ///2: (Para imagenes locales que se suben al servidor)
    ///- No hay Id (se supone que es nuevo)
    ///- Se envia image data
    ///- El Hash debe estar lleno
    ///- La URL debe estar vacio
    func save(db: any Database, imageUrlServerDto: ImageURLServerDTO?, syncToken: Int64) async throws -> UUID? {
        guard let imageUrlDto = imageUrlServerDto else {
            return nil
        }
        //No se permite edicion de ImagenUrl, en todo caso crear uno nuevo
        if let imageId = imageUrlDto.id {
            guard let imageUrl = try await ImageUrl.find(imageId, on: db) else {
                throw Abort(.badRequest, reason: "La imagen con el ID proporcionado no existe")
            }
            return imageUrl.id
        }
        //In CREATION we try to find if image exist by Hash, URL
        let typeOfCreation: TypeOfCreation = try self.getTypeOfCreation(dto: imageUrlDto)
        
        switch typeOfCreation {
        case .createByURL(let url, let hash):
            //Find by URL
            print("Se creará una nueva imagen por URL")
            if let imageUrl = try await getImageUrlByUrl(url: url, db: db) {
                return imageUrl.id
            }
            //Create a new image by URL
            let newImageUrlId = UUID()
            let imageUrlNew = ImageUrl(
                id: newImageUrlId,
                imageUrl: url,
                imageHash: hash,
                syncToken: syncToken
            )
            try await imageUrlNew.save(on: db)
            return imageUrlNew.id
        case .createByData(let data, let hash):
            //Find by Hash
            print("Se creará una nueva imagen por Data")
            if let imageUrl = try await getImageUrlByHash(hash: hash, db: db) {
                return imageUrl.id
            }
            //Create a new image by URL
            let newImageUrlId = UUID()
            let imageUrlNew = ImageUrl(
                id: newImageUrlId,
                imageUrl: getDomainUrl() + "imageUrls/" + newImageUrlId.uuidString,
                imageHash: hash,
                syncToken: syncToken
            )
            //Crear nueva ImagenUrl
            if !fileExists(id: newImageUrlId) {
                //Save imageData in localStorage
                try createFile(id: newImageUrlId, imageData: data)
                guard fileExists(id: newImageUrlId) else {
                    throw Abort(.badRequest, reason: "Se verifico que la imagen creada no existe")
                }
            }
            try await imageUrlNew.save(on: db)
            return newImageUrlId
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
    ///Metodos para guardar una imagen
    ///1: (Para imagenes de internet que solo tienen URL)
    ///- No hay Id (se supone que es nuevo)
    ///- Se envia la URL
    ///- Se envia el Hash
    ///- El image data debe estar vacio
    ///2: (Para imagenes locales que se suben al servidor)
    ///- No hay Id (se supone que es nuevo)
    ///- Se envia image data
    ///- Se envia el Hash
    ///- La URL debe estar vacio
    private func getTypeOfCreation(dto: ImageURLServerDTO) throws -> TypeOfCreation {
        if dto.id == nil,
           let imageURL = dto.imageUrl,
           let imageHash = dto.imageHash,
           imageHash != "",
           dto.imageData == nil {
            return .createByURL(url: imageURL, hash: imageHash)
        }
        if dto.id == nil,
           let imageData = dto.imageData,
           let imageHash = dto.imageHash,
           imageHash != "",
           dto.imageUrl == nil {
            return .createByData(data: imageData, hash: imageHash)
        }
        throw Abort(.badRequest, reason: "Deben enviarse datos de la imagen o la URL de la imagen")
    }
    private func getImageUrlByHash(hash: String, db: any Database) async throws -> ImageUrl? {
        return try await ImageUrl.query(on: db)
            .filter(\.$imageHash == hash)
            .first()
    }
    private func getImageUrlByUrl(url: String, db: any Database) async throws -> ImageUrl? {
        return try await ImageUrl.query(on: db)
            .filter(\.$imageUrl == url)
            .first()
    }
}
