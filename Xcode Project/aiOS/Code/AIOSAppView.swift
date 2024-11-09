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
        // Create initial array with mock chat
        var initialChats: [Chat] = [
            Chat(title: "Mock Chat", chatAI: MockChatAI())
        ]
        
        // Add a chat for each api that has a key
        @Keychain(.apiKeys) var storedKeys: [API.Key]?
        
        for api in API.Identifier.allCases {
            if let key = storedKeys?.first(where: { $0.apiIdentifier == api }) {
                initialChats += Chat(
                    title: api.displayName,
                    chatAI: api.defaultChatAI(withKeyValue: key.value)
                )
            }
        }
        
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
