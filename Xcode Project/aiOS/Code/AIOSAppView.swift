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
            .navigationTitle("Chats")
        } detail: {
            if let selectedChat {
                ChatView(chat: selectedChat)
            }
        }
    }
     
    @State var selectedChat: Chat?
    
    @State var chats = [
        Chat(title: "Grok Beta",
             chatAI: .grokBeta(key: .xAI)),
        Chat(title: "Claude 3.5 Sonnet",
             chatAI: .claude_3_5_Sonnet(key: .anthropic)),
        Chat(title: "ChatGPT 4o",
             chatAI: .gpt_4o(key: .openAI))
    ]
}
