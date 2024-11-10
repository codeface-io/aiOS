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
                        guard let chatAI = viewModel.chatAIs.first else { return }
                        viewModel.chats += Chat(title: "New Chat", chatAI: chatAI)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(viewModel.chatAIs.isEmpty)
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
    @Published var chats = [Chat(title: "Mock Chat", chatAI: MockChatAI())]
    @Published var chatAIs = getAvailableChatAIs()
}

private func getAvailableChatAIs() -> [ChatAI] {
    @Keychain(.apiKeys) var keys: [API.Key]?
    
    return API.Identifier.allCases.compactMap { supportedAPI in
        if let matchingKey = keys?.first(where: { $0.apiIdentifier == supportedAPI }) {
            return supportedAPI.defaultChatAI(withKeyValue: matchingKey.value)
        }
        return nil
    } + [MockChatAI()]
}

private func getAvailableChats() -> [Chat] {
    @Keychain(.apiKeys) var keys: [API.Key]?

    return API.Identifier.allCases.compactMap { api in
        if let key = keys?.first(where: { $0.apiIdentifier == api }) {
            return Chat(title: api.displayName + " Chat",
                        chatAI: api.defaultChatAI(withKeyValue: key.value))
        } else {
            return nil
        }
    } + Chat(title: "Mock Chat", chatAI: MockChatAI())
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
