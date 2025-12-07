import Vapor

extension Application {
    func configLogger() {
        guard let logLevelString = Environment.get(EnvironmentVariables.logLevel.rawValue) else {
            fatalError("must set \(EnvironmentVariables.logLevel.rawValue)")
        }
        guard let level = Logger.Level(rawValue: logLevelString.lowercased()) else {
            fatalError("must set a valid \(EnvironmentVariables.logLevel.rawValue)")
        }
        self.logger.logLevel = level
    }
}

