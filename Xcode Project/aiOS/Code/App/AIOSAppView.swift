import SwiftUI
import SwiftAI

#Preview {
    AIOSAppView()
}

struct AIOSAppView: View {
    var body: some View {
        NavigationSplitView {
            ChatListView(viewModel: viewModel)
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
                        .disabled(apiKeys.chatAIOptions.isEmpty)
                    }
                }
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
    @ObservedObject var apiKeys = APIKeys.shared
}
