import SwiftUI

#Preview {
    NavigationStack {
        ChatPreview()
    }
}

struct ChatPreview: View {
    var body: some View {
        ChatView(chat: chat)
    }
    
    @StateObject var chat = Chat.mock
}

struct ChatView: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ChatMessageList(chat: chat)
                    .scrollContentBackground(.hidden)
                    .onChange(of: chat.scrollDestinationMessageID) { _, newID in
                        guard let newID else { return }
                        
                        Task {
                            try? await Task.sleep(for: .milliseconds(10))
                            withAnimation {
                                scrollView.scrollTo(newID, anchor: .bottom)
                            }
                        }
                    }
            }
                
            InputView(chat: chat)
        }
        .background(Color.dynamic(.aiOSLevel0))
        .navigationTitle(chat.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("AI", selection: $chat.chatAIOption) {
                    ForEach(apiKeys.chatAIOptions) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    @ObservedObject var chat: Chat
    @ObservedObject var apiKeys = APIKeys.shared
}

struct ChatMessageList: View {
    var body: some View {
        List {
            ForEach(chat.messages) { message in
                MessageView(message: message)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                    .padding(.vertical, verticalSpacing / 2)
                    .swipeActions(edge: .leading) {
                        Button {
                            Clipboard.save(message.content)
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
                    .contextMenu {
                        Button {
                            chat.messages.removeAll { $0.id == message.id }
                        } label: {
                            Label("Delete", systemImage: "trash")
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
            .onMove(perform: move)
            .onDelete(perform: chat.deleteItems)
        }
        .listStyle(.plain)
        .moveDisabled(false)
        #if !os(macOS)
        .animation(.default, value: chat.messages) // it just looks broken on macOS
        #endif
    }
    
    #if !os(macOS)
    @Environment(\.editMode) private var editMode
    #endif
    
    private func move(from source: IndexSet, to destination: Int) {
        chat.messages.move(fromOffsets: source, toOffset: destination)
    }
    
    @ObservedObject var chat: Chat
}

private var verticalSpacing: CGFloat { 16 }
