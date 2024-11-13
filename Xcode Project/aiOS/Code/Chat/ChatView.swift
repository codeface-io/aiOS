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
                    ForEach(optionsProvider.chatAIOptions) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    @ObservedObject var chat: Chat
    @StateObject var optionsProvider = ChatAIOptionsProvider()
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
            }
            .onDelete(perform: chat.deleteItems)
        }
        .listStyle(.plain)
        .animation(.default, value: chat.messages)
    }
    
    @ObservedObject var chat: Chat
}

private var verticalSpacing: CGFloat { 16 }
