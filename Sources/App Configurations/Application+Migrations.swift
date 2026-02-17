import Vapor
import Fluent

extension Application {
    func configureMigrations() {
        self.migrations.add(CreateCompany())
        self.migrations.add(CreateSubsidiary())
        self.migrations.add(CreateCustomer())
        self.migrations.add(CreateProduct())
        self.migrations.add(CreateProductSubsidiary())
        self.migrations.add(CreateEmployee())
        self.migrations.add(CreateEmployeeSubsidiary())
        self.migrations.add(CreateSale())
        self.migrations.add(CreateSaleDetail())
        // futuras migraciones aquí
        self.migrations.add(SetNotNullRoundingFields())
    }
}
