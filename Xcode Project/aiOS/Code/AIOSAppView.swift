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
    
    @State var chats: [Chat] = [
        Chat(title: "Chat with Grok",
             chatBotType: Grok.self,
             chatBotKey: .xAI)
    ]
}
