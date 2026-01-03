import Foundation
import FlorShopDTOs
import Fluent

//MARK: Model to DTO
extension Product {
    func toProductDTO() -> ProductClientDTO {
        return ProductClientDTO(
            productCic: productCic,
            productName: productName,
            barCode: barCode,
            unitType: unitType,
            syncToken: syncToken,
            companyCic: company.companyCic,
            imageUrl: imageUrl,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension ProductSubsidiary {
    func toProductSubsidiaryDTO() -> ProductSubsidiaryClientDTO {
        return ProductSubsidiaryClientDTO(
            id: id!,
            active: active,
            expirationDate: expirationDate,
            quantityStock: quantityStock,
            unitCost: unitCost,
            unitPrice: unitPrice,
            syncToken: syncToken,
            subsidiaryCic: subsidiary.subsidiaryCic,
            productCic: product.productCic,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension Company {
    func toCompanyDTO() -> CompanyClientDTO {
        return CompanyClientDTO(
            companyCic: companyCic,
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
            customerCic: customerCic,
            name: name,
            lastName: lastName,
            totalDebt: totalDebt,
            creditScore: creditScore,
            creditDays: creditDays,
            isCreditLimitActive: isCreditLimitActive,
            isDateLimitActive: isDateLimitActive,
            dateLimit: dateLimit,
            lastDatePurchase: lastDatePurchase,
            phoneNumber: phoneNumber,
            creditLimit: creditLimit,
            syncToken: syncToken,
            companyCic: company.companyCic,
            imageUrl: imageUrl,
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
            subsidiaryCic: self.subsidiary.subsidiaryCic,
            customerCic: self.customer?.customerCic,
            employeeCic: self.employeeSubsidiary.employee.employeeCic,
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
            imageUrl: imageUrl,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension Subsidiary {
    func toSubsidiaryDTO() -> SubsidiaryClientDTO {
        return SubsidiaryClientDTO(
            subsidiaryCic: subsidiaryCic,
            name: name,
            syncToken: syncToken,
            companyCic: self.company.companyCic,
            imageUrl: imageUrl,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension Employee {
    func toEmployeeDTO() -> EmployeeClientDTO {
        return EmployeeClientDTO(
            employeeCic: employeeCic,
            name: name,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            syncToken: syncToken,
            companyCic: self.company.companyCic,
            imageUrl: imageUrl,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}

extension EmployeeSubsidiary {
    func toEmployeeSubsidiaryDTO() -> EmployeeSubsidiaryClientDTO {
        return EmployeeSubsidiaryClientDTO(
            role: role,
            active: active,
            syncToken: syncToken,
            subsidiaryCic: self.subsidiary.subsidiaryCic,
            employeeCic: self.employee.employeeCic,
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
extension Array where Element == ProductSubsidiary {
    func mapToListProductSubsidiaryDTO() -> [ProductSubsidiaryClientDTO] {
        return self.compactMap({$0.toProductSubsidiaryDTO()})
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
extension Array where Element == EmployeeSubsidiary {
    func mapToListEmployeeSubsidiaryDTO() -> [EmployeeSubsidiaryClientDTO] {
        return self.compactMap({$0.toEmployeeSubsidiaryDTO()})
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
