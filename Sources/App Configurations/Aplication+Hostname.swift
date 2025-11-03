import Vapor

extension Application {
    func getHostname() -> String {
        guard let hostname = Environment.get("HTTP_SERVER_HOST") else {
            fatalError("Missing HTTP_SERVER_HOST in configuration in .env\(self.environment)")
        }
        return hostname
    }
    func getPort() -> Int {
        guard let port = Environment.get("HTTP_SERVER_PORT"),
              let portInt = Int(port) else {
            fatalError("Missing HTTP_SERVER_PORT in configuration in .env\(self.environment)")
        }
        return portInt
    }
}
