import SwiftAI
import FoundationToolz
import Foundation
import SwiftyToolz

class ChatAIOptionsProvider: ObservableObject {
    @Published var chatAIOptions: [ChatAIOption] = getDefaultChatAIOptionsForSupportedAPIs()
}

private func getDefaultChatAIOptionsForSupportedAPIs() -> [ChatAIOption] {
    return API.Identifier.allCases.compactMap { supportedAPI in
        if let matchingKey = API.keys?.first(where: { $0.apiIdentifier == supportedAPI }) {
            return ChatAIOption(
                chatAI: supportedAPI.defaultChatAI(withKeyValue: matchingKey.value),
                displayName: supportedAPI.displayName
            )
        }
        return nil
    } + .mock
}

private extension API.Identifier {
    func defaultChatAI(withKeyValue keyValue: String) -> ChatAI {
        switch self {
        case .anthropic:
            Anthropic.Claude(.claude_3_5_Sonnet, key: .init(keyValue))
        case .openAI:
            OpenAI.ChatGPT(.gpt_4o, key: .init(keyValue))
        case .xAI:
            XAI.Grok(.grokBeta, key: .init(keyValue))
        }
    }
}
