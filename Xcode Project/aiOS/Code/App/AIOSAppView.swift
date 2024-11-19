import SwiftUI
import SwiftAI

#Preview {
    AIOSAppView()
}

struct AIOSAppView: View {
    var body: some View {
        NavigationSplitView {
            ChatListView(chatList: chatList)
                .toolbar {
#if !os(macOS)
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showsSettings = true
                        } label: {
                            Image(systemName: "key.horizontal")
                        }
                    }
#endif
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            chatList.addNewChat()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .disabled(apiKeys.chatAIOptions.isEmpty)
                    }
                }
        } detail: {
            if let selectedChat = chatList.selectedChat {
                ChatView(chat: selectedChat)
            }
        }
#if !os(macOS)
        .sheet(isPresented: $showsSettings) {
            APIKeySettingsView()
        }
#endif
    }
    
    @StateObject var chatList = ChatList()
    @ObservedObject var apiKeys = APIKeys.shared
    @State var showsSettings = false
}
