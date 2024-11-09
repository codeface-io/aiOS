extension API.Key {
    var apiIdentifier: API.Identifier? {
        .init(rawValue: apiIdentifierValue)
    }
}

extension API {
    enum Identifier: String, CaseIterable, Identifiable {
        var displayName: String {
            switch self {
            case .anthropic: "Anthropic"
            case .openAI: "OpenAI"
            case .xAI: "xAI"
            }
        }
        
        var id: String { rawValue }
        
        case xAI
        case anthropic
        case openAI
    }
}
