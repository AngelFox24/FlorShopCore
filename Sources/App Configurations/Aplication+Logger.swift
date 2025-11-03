import Vapor

extension Application {
    func configLogger() throws {
        guard let logLevelString = Environment.get("LOG_LEVEL") else {
            fatalError("must set LOG_LEVEL")
        }
        guard let level = Logger.Level(rawValue: logLevelString.lowercased()) else {
            fatalError("must set a valid LOG_LEVEL")
        }
        self.logger.logLevel = level
    }
}

