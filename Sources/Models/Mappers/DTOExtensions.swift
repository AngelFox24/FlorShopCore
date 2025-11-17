import FlorShopDTOs

extension CompanyServerDTO {
    func isEqual(to other: Company) -> Bool {
        return (
            self.companyName == other.companyName &&
            self.ruc == other.ruc
        )
    }
    func clean() -> CompanyServerDTO {
        return CompanyServerDTO(
            companyCic: self.companyCic,
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
            subsidiaryCic: self.subsidiaryCic,
            name: self.name.cleaned,
            imageUrl: self.imageUrl
        )
    }
}
extension ProductServerDTO {
    func isMainEqual(to other: Product) -> Bool {
        return (
            self.barCode == other.barCode &&
            self.productName == other.productName &&
            self.unitType == other.unitType
        )
    }
    func isChildEqual(to other: ProductSubsidiary) -> Bool {
        return (
            self.active == other.active &&
            self.expirationDate == other.expirationDate &&
            self.quantityStock == other.quantityStock &&
            self.unitCost == other.unitCost &&
            self.unitPrice == other.unitPrice
        )
    }
}
