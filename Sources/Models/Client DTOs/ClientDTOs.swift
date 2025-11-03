import Vapor
import FlorShop_DTOs

extension ImageURLClientDTO: @retroactive Content {}
extension CompanyClientDTO: @retroactive Content {}
extension SubsidiaryClientDTO: @retroactive Content {}
extension EmployeeClientDTO: @retroactive Content {}
extension CustomerClientDTO: @retroactive Content {}
extension ProductClientDTO: @retroactive Content {}
extension SaleClientDTO: @retroactive Content {}
extension SaleDetailClientDTO: @retroactive Content {}

