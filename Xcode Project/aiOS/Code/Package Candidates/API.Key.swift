import Foundation

enum API {
    /// a flexible and future proof way to configure and store api keys. a client does not need to make use of the flexibility and can for instance just assume one key per API without name and description
    struct Key: Codable, Identifiable {
        init?(_ keyValue: String,
             apiIdentifierValue: String,
             name: String? = nil,
             description: String? = nil,
             id: UUID = UUID()) {
            if keyValue.isEmpty { return nil }
            self.id = id
            self.value = keyValue
            self.apiIdentifierValue = apiIdentifierValue
            self.name = name
            self.description = description
        }
        
        let id: UUID
        let value: String
        let apiIdentifierValue: String
        let name: String?
        let description: String?
    }
}
