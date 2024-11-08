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

    @State var chats = [
        Chat(title: "Mock Chat",
             chatAI: MockChatAI()),
        
        Chat(title: "Grok Beta",
             chatAI: XAI.Grok(.grokBeta,
                              key: .xAI)),
        Chat(title: "Claude 3.5 Sonnet",
             chatAI: Anthropic.Claude(.claude_3_5_Sonnet,
                                      key: .anthropic)),
        Chat(title: "ChatGPT 4o",
             chatAI: OpenAI.ChatGPT(.gpt_4o,
                                    key: .openAI))
    ]
}
