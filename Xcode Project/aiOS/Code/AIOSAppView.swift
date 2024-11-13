import SwiftUI
import SwiftAI
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
            
            .toolbar {
                #if !os(macOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showsSettings = true
                    } label: {
                        Image(systemName: "key.horizontal")
                    }
                }
                #endif
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.addNewChat()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(optionsProvider.chatAIOptions.isEmpty)
                }
            }
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
    @StateObject var optionsProvider = ChatAIOptionsProvider()
}

@MainActor
class AIOSAppViewModel: ObservableObject {
    func addNewChat() {
        let options = getDefaultChatAIOptionsForSupportedAPIs()
        guard let option = options.first else { return }
        let newChat = Chat(title: "New \(option.displayName) Chat",
                           chatAIOption: option)
        chats += newChat
        
        Task { @MainActor in
            self.selectedChat = newChat
        }
    }
    
    @Published var showsSettings = false
    @Published var selectedChat: Chat?
    @Published var chats = [Chat.mock]
}
