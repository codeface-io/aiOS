import SwiftUI

struct ChatListView: View {
    var body: some View {
        List(selection: $viewModel.selectedChat) {
            Section(header: Text("iCloud")) {
                
            }
            
            Section(header: Text(deviceName)) {
                ForEach(viewModel.localChats) { chat in
                    NavigationLink(value: chat) {
                        ChatListItemView(chat: chat)
                    }
#if os(macOS)
                    .swipeActions(edge: .trailing) {
                        Button {
                            if viewModel.selectedChat === chat {
                                viewModel.selectedChat = nil
                            }
                            
                            viewModel.chats.removeAll { $0 === chat }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
#endif
                }
#if !os(macOS)
                .onDelete { viewModel.removeChats(at: $0) }
#endif
            }
            .onAppear {
                viewModel.loadLocalChats()
            }
        }
        .moveDisabled(false)
#if !os(macOS)
        .animation(.default, value: viewModel.localChats) // it just looks broken on macOS
#endif
        .navigationTitle("Chats")
    }
    
    @ObservedObject var viewModel: ChatList
}

#if os(macOS)
var deviceName: String { "This Mac" }
#else
import UIKit
var deviceName: String { UIDevice.current.name }
#endif
