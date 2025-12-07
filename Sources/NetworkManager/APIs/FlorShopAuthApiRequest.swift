import Foundation
import FlorShopDTOs

enum FlorShopAuthApiRequest {
    case updateCompany(request: CompanyServerDTO, internalToken: String)
    case saveSubsidiary(request: RegisterSubsidiaryRequest, internalToken: String)
    case updateUserSubsidiary(request: UpdateUserSubsidiaryRequest, internalToken: String)
}

extension FlorShopAuthApiRequest: NetworkRequest {
    var url: URL? {
        let baseUrl = AppConfig.florShopAuthBaseURL
        let path: String
        switch self {
        case .updateCompany:
            path = "/company"
        case .saveSubsidiary:
            path = "/subsidiary"
        case .updateUserSubsidiary:
            path = "/usersubsidiary"
        }
        return URL(string: baseUrl + path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateCompany:
                .post
        case .saveSubsidiary:
                .post
        case .updateUserSubsidiary:
                .post
        }
    }
    
    var headers: [HTTPHeader : String]? {
        var headers: [HTTPHeader: String] = [:]
        switch self {
        case .updateCompany(_, let internalToken):
            headers[.contentType] = ContentType.json.rawValue
            headers[.authorization] = "Bearer \(internalToken)"
        case .saveSubsidiary(_, let internalToken):
            headers[.contentType] = ContentType.json.rawValue
            headers[.authorization] = "Bearer \(internalToken)"
        case .updateUserSubsidiary(_, let internalToken):
            headers[.contentType] = ContentType.json.rawValue
            headers[.authorization] = "Bearer \(internalToken)"
        }
        return headers
    }
    
    var parameters: (any Encodable)? {
        switch self {
        case .updateCompany(let request, _):
            return request
        case .saveSubsidiary(let request, _):
            return request
        case .updateUserSubsidiary(let request, _):
            return request
        }
    }
}
