import SwiftUI
import SwiftAI
import FoundationToolz
import SwiftyToolz

#Preview {
    AIOSAppView()
}

struct AIOSAppView: View {
    var body: some View {
        NavigationSplitView {
            List(viewModel.chats, selection: $viewModel.selectedChat) { chat in
                NavigationLink(value: chat) {
                    Label(chat.title,
                          systemImage: "bubble.left.and.bubble.right")
                }
            }
            
            .toolbar {
                #if !os(macOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showsSettings = true
                    } label: {
                        Image(systemName: "key")
                    }
                }
                #endif
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        guard let option = viewModel.chatAIOptions.first else { return }
                        viewModel.chats += Chat(title: option.displayName + " Chat",
                                                chatAIOption: option)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(viewModel.chatAIOptions.isEmpty)
                }
            }
            .navigationTitle("Chats")
        } detail: {
            if let selectedChat = viewModel.selectedChat {
                ChatView(chat: selectedChat)
            }
        }
        #if !os(macOS)
        .sheet(isPresented: $viewModel.showsSettings) {
            APIKeySettingsView()
        }
        #endif
    }
    
    @StateObject var viewModel = AIOSAppViewModel()
}

class AIOSAppViewModel: ObservableObject {
    @Published var showsSettings = false
    @Published var selectedChat: Chat?
    @Published var chats = [Chat.mock]
    @Published var chatAIOptions = getDefaultChatAIOptionsForSupportedAPIs()
}

private func getDefaultChatAIOptionsForSupportedAPIs() -> [ChatAIOption] {
    @Keychain(.apiKeys) var keys: [API.Key]?
    
    return .mock + API.Identifier.allCases.compactMap { supportedAPI in
        if let matchingKey = keys?.first(where: { $0.apiIdentifier == supportedAPI }) {
            return ChatAIOption(
                chatAI: supportedAPI.defaultChatAI(withKeyValue: matchingKey.value),
                displayName: supportedAPI.displayName
            )
        }
        return nil
    }
}

private func getAvailableChats() -> [Chat] {
    @Keychain(.apiKeys) var keys: [API.Key]?

    return .mock + API.Identifier.allCases.compactMap { api in
        if let key = keys?.first(where: { $0.apiIdentifier == api }) {
            let option = ChatAIOption(
                chatAI: api.defaultChatAI(withKeyValue: key.value),
                displayName: api.displayName
            )
            
            return Chat(title: api.displayName + " Chat",
                        chatAIOption: option)
        } else {
            return nil
        }
    }
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
