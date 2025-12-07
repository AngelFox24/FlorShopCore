import Vapor

extension Application {
    func getHostname() -> String {
        guard let hostname = Environment.get(EnvironmentVariables.httpServerHost.rawValue) else {
            fatalError("Missing \(EnvironmentVariables.httpServerHost.rawValue) in configuration in .env\(self.environment)")
        }
        return hostname
    }
    func getPort() -> Int {
        guard let port = Environment.get(EnvironmentVariables.httpServerPort.rawValue),
              let portInt = Int(port) else {
            fatalError("Missing \(EnvironmentVariables.httpServerPort.rawValue) in configuration in .env\(self.environment)")
        }
        return portInt
    }
}
