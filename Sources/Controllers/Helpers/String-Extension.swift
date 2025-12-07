extension String {
    var cleaned: String {
        self
            // Reemplaza saltos de línea (\n) con un espacio
            .replacingOccurrences(of: "\n", with: " ")
            // Reemplaza retornos de carro (\r) con un espacio
            .replacingOccurrences(of: "\r", with: " ")
            // Reemplaza múltiples espacios, tabs y otros espacios repetidos por un solo espacio
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            // Elimina espacios al inicio y al final del string
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
