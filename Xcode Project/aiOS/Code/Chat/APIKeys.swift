import SwiftAI
import FoundationToolz
import Foundation

extension API {
    @Keychain.Item(.apiKeys) static var keys: [API.Key]?
}

extension Keychain.ItemDescription {
    static let apiKeys = Keychain.ItemDescription(
        tag: Data(utf8String: "apiKeys"),
        class: .key
    )
}
