import FlorShop_DTOs

extension CompanyServerDTO {
    func isEqual(to other: Company) -> Bool {
        return (
            self.companyName == other.companyName &&
            self.ruc == other.ruc
        )
    }
    func clean() -> CompanyServerDTO {
        return CompanyServerDTO(
            id: self.id,
            companyName: self.companyName.cleaned,
            ruc: self.ruc.cleaned
        )
    }
}
extension SubsidiaryServerDTO {
    func isEqual(to other: Subsidiary) -> Bool {
        return (
            self.name == other.name
        )
    }
    func clean() -> SubsidiaryServerDTO {
        return SubsidiaryServerDTO(
            id: self.id,
            name: self.name.cleaned,
            companyID: self.companyID,
            imageUrl: self.imageUrl
        )
    }
}
