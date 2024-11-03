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
                GrokChatView(chat: selectedChat)
            }
        }
    }
     
    @State var selectedChat: GrokChat?
    
    @State var chats = [
        GrokChat(title: "Chat with Grok", apiKey: .xAI)
    ]
}
