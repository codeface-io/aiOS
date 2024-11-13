import SwiftAI
import FoundationToolz
import Foundation
import Combine
import SwiftyToolz

class APIKeys: ObservableObject {
    func keyValue(for api: API.Identifier) -> String? {
        keys?.first { $0.apiIdentifier == api }?.value
    }
    
    func set(keyValue: String, for api: API.Identifier) {
        if keyValue.isEmpty {
            keys?.removeAll { $0.apiIdentifier == api }
        } else if let originalIndex = keys?.firstIndex(where: { $0.apiIdentifier == api }),
                  let originalKey = keys?[originalIndex] {
            if let updatedKey = API.Key(
                keyValue,
                apiIdentifierValue: api.rawValue,
                name: originalKey.name,
                description: originalKey.description,
                id: originalKey.id
            ) {
                keys?[originalIndex] = updatedKey
            }
        } else {
            if let newKey = API.Key(
                keyValue,
                apiIdentifierValue: api.rawValue
            ) {
                keys = (keys ?? []) + newKey
            }
        }
    }
    
    static let shared = APIKeys()
    
    private init() { observeKeys() }
    
    func observeKeys() {
        keysObservation = $keys.dropFirst().sink { keys in
            Self.storedKeys = keys
            self.chatAIOptions = getDefaultChatAIOptions(for: keys)
        }
    }
    
    private var keysObservation: AnyCancellable?
    
    @Published var chatAIOptions: [ChatAIOption] = getDefaultChatAIOptions(for: storedKeys)
    @Published var keys: [API.Key]? = storedKeys
    
    @Keychain.Item(.apiKeys) private static var storedKeys: [API.Key]?
}

extension Keychain.ItemDescription {
    static let apiKeys = Keychain.ItemDescription(
        tag: Data(utf8String: "apiKeys"),
        class: .key
    )
}

private func getDefaultChatAIOptions(for keys: [API.Key]?) -> [ChatAIOption] {
    var result: [ChatAIOption] = API.Identifier.allCases.compactMap { api in
        guard let matchingKey = keys?.first(where: { $0.apiIdentifier == api }) else {
            return nil
        }
        
        return api.defaultChatAIOption(withKeyValue: matchingKey.value)
    }
    
    #if DEBUG
    result += .mock
    #endif
    
    return result
}

private extension API.Identifier {
    func defaultChatAIOption(withKeyValue keyValue: String) -> ChatAIOption {
        switch self {
        case .anthropic:
            ChatAIOption(
                chatAI: Anthropic.Claude(.claude_3_5_Sonnet, key: .init(keyValue)),
                displayName: "Claude Sonnet 3.5"
            )
        case .openAI:
            ChatAIOption(
                chatAI: OpenAI.ChatGPT(.gpt_4o, key: .init(keyValue)),
                displayName: "ChatGPT 4o"
            )
        case .xAI:
            ChatAIOption(
                chatAI: XAI.Grok(.grokBeta, key: .init(keyValue)),
                displayName: "Grok Beta"
            )
        }
    }
}
