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
    init() {
        @Keychain(.apiKeys) var keys: [API.Key]?
        
        // Create initial array of chats
        let initialChats: [Chat] = API.Identifier.allCases.compactMap { api in
            if let key = keys?.first(where: { $0.apiIdentifier == api }) {
                return (api, key.value)
            } else {
                return nil
            }
        }.map { api, keyValue in
            Chat(title: api.displayName + " Chat",
                 chatAI: api.defaultChatAI(withKeyValue: keyValue))
        } + Chat(title: "Mock Chat", chatAI: MockChatAI())
        
        _chats = Published(initialValue: initialChats)
    }
    
    @Published var showsSettings = false
    @Published var selectedChat: Chat?
    @Published var chats: [Chat]
}

extension API.Identifier {
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
