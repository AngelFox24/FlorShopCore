import Foundation
//MARK: Model to DTO
extension Product {
    func toProductDTO() -> ProductOutputDTO {
        return ProductOutputDTO(
            id: id!,
            productName: productName,
            barCode: barCode,
            active: active,
            expirationDate: expirationDate,
            quantityStock: quantityStock,
            unitType: unitType,
            unitCost: unitCost,
            unitPrice: unitPrice,
            syncToken: syncToken,
            subsidiaryId: self.$subsidiary.id,
            imageUrlId: imageUrl?.id,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension ImageUrl {
    func toImageUrlDTO() -> ImageURLOutputDTO {
        return ImageURLOutputDTO(
            id: id!,
            imageUrl: imageUrl,
            imageHash: imageHash,
            syncToken: syncToken,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension Company {
    func toCompanyDTO() -> CompanyOutputDTO {
        return CompanyOutputDTO(
            id: id!,
            companyName: companyName,
            ruc: ruc,
            syncToken: syncToken,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension Customer {
    func toCustomerDTO() -> CustomerOutputDTO {
        return CustomerOutputDTO(
            id: id!,
            name: name,
            lastName: lastName,
            totalDebt: totalDebt,
            creditScore: creditScore,
            creditDays: creditDays,
            isCreditLimitActive: isCreditLimitActive,
            isCreditLimit: isCreditLimit,
            isDateLimitActive: isDateLimitActive,
            isDateLimit: isDateLimit,
            dateLimit: dateLimit,
            lastDatePurchase: lastDatePurchase,
            phoneNumber: phoneNumber,
            creditLimit: creditLimit,
            syncToken: syncToken,
            companyID: self.$company.id,
            imageUrlId: imageUrl?.id,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension Sale {
    func toSaleDTO() -> SaleOutputDTO {
        return SaleOutputDTO(
            id: id!,
            paymentType: paymentType,
            saleDate: saleDate,
            total: total,
            syncToken: syncToken,
            subsidiaryId: self.$subsidiary.id,
            customerId: self.$customer.id,
            employeeId: self.$employee.id,
            saleDetail: self.toSaleDetail.mapToListSaleDetailDTO(),
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension SaleDetail {
    func toSaleDetailDTO() -> SaleDetailOutputDTO {
        return SaleDetailOutputDTO(
            id: id!,
            productName: productName,
            barCode: barCode,
            quantitySold: quantitySold,
            subtotal: subtotal,
            unitType: unitType,
            unitCost: unitCost,
            unitPrice: unitPrice,
            syncToken: syncToken,
            saleID: self.$sale.id,
            imageUrlId: imageUrl?.id,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension Subsidiary {
    func toSubsidiaryDTO() -> SubsidiaryOutputDTO {
        return SubsidiaryOutputDTO(
            id: id!,
            name: name,
            syncToken: syncToken,
            companyID: self.$company.id,
            imageUrlId: imageUrl?.id,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension Employee {
    func toEmployeeDTO() -> EmployeeOutputDTO {
        return EmployeeOutputDTO(
            id: id!,
            user: user,
            name: name,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            role: role,
            active: active,
            syncToken: syncToken,
            subsidiaryID: self.$subsidiary.id,
            imageUrlId: imageUrl?.id,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}
//MARK: Array of Model
extension Array where Element == Product {
    func mapToListProductDTO() -> [ProductOutputDTO] {
        return self.compactMap({$0.toProductDTO()})
    }
}
extension Array where Element == SaleDetail {
    func mapToListSaleDetailDTO() -> [SaleDetailOutputDTO] {
        return self.compactMap({$0.toSaleDetailDTO()})
    }
}
extension Array where Element == Company {
    func mapToListCompanyDTO() -> [CompanyOutputDTO] {
        return self.compactMap({$0.toCompanyDTO()})
    }
}
extension Array where Element == Customer {
    func mapToListCustomerDTO() -> [CustomerOutputDTO] {
        return self.compactMap({$0.toCustomerDTO()})
    }
}
extension Array where Element == Employee {
    func mapToListEmployeeDTO() -> [EmployeeOutputDTO] {
        return self.compactMap({$0.toEmployeeDTO()})
    }
}
extension Array where Element == ImageUrl {
    func mapToListImageURLDTO() -> [ImageURLOutputDTO] {
        return self.compactMap({$0.toImageUrlDTO()})
    }
}
extension Array where Element == Subsidiary {
    func mapToListSubsidiaryDTO() -> [SubsidiaryOutputDTO] {
        return self.compactMap({$0.toSubsidiaryDTO()})
    }
}
extension Array where Element == Sale {
    func mapToListSaleDTO() -> [SaleOutputDTO] {
        return self.compactMap({$0.toSaleDTO()})
    }
}
