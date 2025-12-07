import Vapor

enum AppConfig {
    static let florShopAuthBaseURL = Environment.get("AUTH_BASE_URL")!
}
