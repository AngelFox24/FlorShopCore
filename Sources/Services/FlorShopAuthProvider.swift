import FlorShopDTOs
import Vapor

struct FlorShopAuthProvider {
    func updateCompany(request: CompanyServerDTO, internalToken: String) async throws {
        let request = FlorShopAuthApiRequest.updateCompany(request: request, internalToken: internalToken)
        let response: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
        guard response.isValid() else {
            throw Abort(.badRequest, reason: "Error al actualizar la compañia en FlorShopAuth")
        }
    }
    func saveSubsidiary(request: RegisterSubsidiaryRequest, internalToken: String) async throws {
        let request = FlorShopAuthApiRequest.saveSubsidiary(request: request, internalToken: internalToken)
        let response: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
        guard response.isValid() else {
            throw Abort(.badRequest, reason: "Error al actualizar la subsidiaria en FlorShopAuth")
        }
    }
    func updateUserSubsidiary(request: UpdateUserSubsidiaryRequest, internalToken: String) async throws {
        let request = FlorShopAuthApiRequest.updateUserSubsidiary(request: request, internalToken: internalToken)
        let response: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
        guard response.isValid() else {
            throw Abort(.badRequest, reason: "Error al actualizar UserSubsidiary en FlorShopAuth")
        }
    }
}
