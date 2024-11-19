import SwiftUI

struct ChatListView: View {
    var body: some View {
        List(selection: $viewModel.selectedChat) {
            Section(header: Text("iCloud Documents")) {
                
            }
            
            Section(header: Text("Documents")) {
                ForEach(viewModel.chats) { chat in
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
                .onDelete { offsets in
                    viewModel.chats.remove(atOffsets: offsets)
                }
#endif
                .onMove(perform: move)
            }
            .onAppear {
                viewModel.loadDocuments()
            }
        }
        .moveDisabled(false)
#if !os(macOS)
        .animation(.default, value: viewModel.chats) // it just looks broken on macOS
#endif
        .navigationTitle("Chats")
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        viewModel.chats.move(fromOffsets: source, toOffset: destination)
    }
    
    @ObservedObject var viewModel: AIOSAppViewModel
}
