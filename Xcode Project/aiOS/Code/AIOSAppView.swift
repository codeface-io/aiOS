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
        let keyStore = AuthenticationKeyEntryStore()
        
        // Create initial array with mock chat
        var initialChats: [Chat] = [
            Chat(title: "Mock Chat",
                 chatAI: MockChatAI())
        ]
        
        // Add a chat for each provider that has a key
        for provider in ProviderIdentifier.allCases {
            if let key = keyStore.keys.first(where: { $0.providerIdentifier == provider }) {
                switch provider {
                case .openAI:
                    initialChats.append(
                        Chat(title: "ChatGPT 4",
                             chatAI: OpenAI.ChatGPT(.gpt_4o,
                                                    key: .init(key.keyValue)))
                    )
                case .anthropic:
                    initialChats.append(
                        Chat(title: "Claude 3.5 Sonnet",
                             chatAI: Anthropic.Claude(.claude_3_5_Sonnet,
                                                      key: .init(key.keyValue)))
                    )
                case .xAI:
                    initialChats.append(
                        Chat(title: "Grok Beta",
                             chatAI: XAI.Grok(.grokBeta,
                                              key: .init(key.keyValue)))
                    )
                }
            }
        }
        
        _chats = State(initialValue: initialChats)
    }
    
    @State var chats: [Chat]
}
