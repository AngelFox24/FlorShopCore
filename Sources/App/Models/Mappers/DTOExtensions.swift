extension CompanyInputDTO {
    func isEqual(to other: Company) -> Bool {
        return (
            self.companyName == other.companyName &&
            self.ruc == other.ruc
        )
    }
    func clean() -> CompanyInputDTO {
        return CompanyInputDTO(
            id: self.id,
            companyName: self.companyName.cleaned,
            ruc: self.ruc.cleaned
        )
    }
}
extension SubsidiaryInputDTO {
    func isEqual(to other: Subsidiary) -> Bool {
        return (
            self.name == other.name
        )
    }
    func clean() -> SubsidiaryInputDTO {
        return SubsidiaryInputDTO(
            id: self.id,
            name: self.name.cleaned,
            companyID: self.companyID,
            imageUrl: self.imageUrl
        )
    }
}
