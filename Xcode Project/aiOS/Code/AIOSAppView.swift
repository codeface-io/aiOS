import SwiftUI
import SwiftAI
import SwiftyToolz

#Preview {
    AIOSAppView()
}

struct AIOSAppView: View {
    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.selectedChat) {
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
            .moveDisabled(false)
            #if !os(macOS)
            .animation(.default, value: viewModel.chats) // it just looks broken on macOS
            #endif
            
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
    
    private func move(from source: IndexSet, to destination: Int) {
        viewModel.chats.move(fromOffsets: source, toOffset: destination)
    }
    
    @StateObject var viewModel = AIOSAppViewModel()
    @ObservedObject var apiKeys = APIKeys.shared
}

struct ChatListItemView: View {
    var body: some View {
        Label {
            if isEditing {
                TextField("Chat Title", text: $chat.title) {
                    isEditing = false
                }
                .focused($fieldIsFocused)
                .onChange(of: fieldIsFocused) { _, isFocused in
                    if !isFocused {
                        isEditing = false
                    }
                }
            } else {
                Text(chat.title)
            }
        } icon: {
            Image(systemName: "bubble.left.and.bubble.right")
        }
        .swipeActions(edge: .leading) {
            Button {
                startEditing()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
        }
        .contextMenu {
            Button {
                startEditing()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            #if !os(macOS)
            Button {
                editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
            } label: {
                Label(editMode?.wrappedValue == .active ? "Done Editing List" : "Edit List",
                      systemImage: editMode?.wrappedValue == .active ? "checkmark" : "arrow.up.arrow.down")
            }
            #endif
        }
    }

    #if !os(macOS)
    @Environment(\.editMode) private var editMode
    #endif
    
    func startEditing() {
        isEditing = true
        fieldIsFocused = true
    }
    
    @FocusState var fieldIsFocused: Bool
    @State private var isEditing = false
    
    @ObservedObject var chat: Chat
}

@MainActor
class AIOSAppViewModel: ObservableObject {
    func addNewChat() {
        guard let option = APIKeys.shared.chatAIOptions.first else { return }

        let newChat = Chat(title: "New Chat", chatAIOption: option)
        
        chats.insert(newChat, at: 0)
        
        Task { @MainActor in
            self.selectedChat = newChat
        }
    }
    
    @Published var showsSettings = false
    @Published var selectedChat: Chat?
    @Published var chats = [Chat]()
}
