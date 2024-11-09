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
            #if !os(macOS)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showsSettings = true
                    } label: {
                        Image(systemName: "key")
                    }
                }
            }
            #endif
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
    @Published var chats = makeInitialChats()
}

private func makeInitialChats() -> [Chat] {
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
