import SwiftUI
import SwiftAI

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
        @Keychain(key: "apiKeys") var storedKeys: [API.Key]?
        
        for api in API.Identifier.allCases {
            if let key = storedKeys?.first(where: { $0.apiIdentifier == api }) {
                switch api {
                case .openAI:
                    initialChats.append(
                        Chat(title: "ChatGPT 4",
                             chatAI: OpenAI.ChatGPT(.gpt_4o,
                                                    key: .init(key.value)))
                    )
                case .anthropic:
                    initialChats.append(
                        Chat(title: "Claude 3.5 Sonnet",
                             chatAI: Anthropic.Claude(.claude_3_5_Sonnet,
                                                      key: .init(key.value)))
                    )
                case .xAI:
                    initialChats.append(
                        Chat(title: "Grok Beta",
                             chatAI: XAI.Grok(.grokBeta,
                                              key: .init(key.value)))
                    )
                }
            }
        }
        
        _chats = State(initialValue: initialChats)
    }
    
    @State var chats: [Chat]
}
