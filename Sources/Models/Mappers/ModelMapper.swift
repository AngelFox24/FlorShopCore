import Foundation
import FlorShop_DTOs
//MARK: Model to DTO
extension Product {
    func toProductDTO() -> ProductClientDTO {
        return ProductClientDTO(
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
    func toImageUrlDTO() -> ImageURLClientDTO {
        return ImageURLClientDTO(
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
    func toCompanyDTO() -> CompanyClientDTO {
        return CompanyClientDTO(
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
    func toCustomerDTO() -> CustomerClientDTO {
        return CustomerClientDTO(
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
    func toSaleDTO() -> SaleClientDTO {
        return SaleClientDTO(
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
    func toSaleDetailDTO() -> SaleDetailClientDTO {
        return SaleDetailClientDTO(
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
    func toSubsidiaryDTO() -> SubsidiaryClientDTO {
        return SubsidiaryClientDTO(
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
    func toEmployeeDTO() -> EmployeeClientDTO {
        return EmployeeClientDTO(
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
    func mapToListProductDTO() -> [ProductClientDTO] {
        return self.compactMap({$0.toProductDTO()})
    }
}
extension Array where Element == SaleDetail {
    func mapToListSaleDetailDTO() -> [SaleDetailClientDTO] {
        return self.compactMap({$0.toSaleDetailDTO()})
    }
}
extension Array where Element == Company {
    func mapToListCompanyDTO() -> [CompanyClientDTO] {
        return self.compactMap({$0.toCompanyDTO()})
    }
}
extension Array where Element == Customer {
    func mapToListCustomerDTO() -> [CustomerClientDTO] {
        return self.compactMap({$0.toCustomerDTO()})
    }
}
extension Array where Element == Employee {
    func mapToListEmployeeDTO() -> [EmployeeClientDTO] {
        return self.compactMap({$0.toEmployeeDTO()})
    }
}
extension Array where Element == ImageUrl {
    func mapToListImageURLDTO() -> [ImageURLClientDTO] {
        return self.compactMap({$0.toImageUrlDTO()})
    }
}
extension Array where Element == Subsidiary {
    func mapToListSubsidiaryDTO() -> [SubsidiaryClientDTO] {
        return self.compactMap({$0.toSubsidiaryDTO()})
    }
}
extension Array where Element == Sale {
    func mapToListSaleDTO() -> [SaleClientDTO] {
        return self.compactMap({$0.toSaleDTO()})
    }
}
