import SwiftUI
import SwiftAI
import SwiftyToolz

#Preview {
    AIOSAppView()
}

struct AIOSAppView: View {
    var body: some View {
        NavigationSplitView {
            List(chats, selection: $selectedChat) { chat in
                NavigationLink(value: chat) {
                    Label(chat.title,
                          systemImage: "bubble.left.and.bubble.right")
                }
            }
            #if !os(macOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showsSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            #endif
            .navigationTitle("Chats")
        } detail: {
            if let selectedChat {
                ChatView(chat: selectedChat)
            }
        }
        #if !os(macOS)
        .sheet(isPresented: $showsSettings) {
            SettingsView()
        }
        #endif
    }
    
    @State var showsSettings = false
    @State var selectedChat: Chat?
    
    init() {
        @Keychain(.apiKeys) var storedKeys: [API.Key]?
        
        // Create initial array of chats
        let initialChats: [Chat] = API.Identifier.allCases.compactMap { api in
            if let key = storedKeys?.first(where: { $0.apiIdentifier == api }) {
                return (api, key.value)
            } else {
                return nil
            }
        }.map { api, keyValue in
            Chat(title: api.displayName,
                 chatAI: api.defaultChatAI(withKeyValue: keyValue))
        } + Chat(title: "Mock Chat", chatAI: MockChatAI())
        
        _chats = State(initialValue: initialChats)
    }
    
    @State var chats: [Chat]
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
