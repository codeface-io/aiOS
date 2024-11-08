import SwiftAI
import SwiftUI
import SwiftyToolz

#Preview {
    NavigationStack {
        ChatPreview()
    }
}

struct ChatPreview: View {
    var body: some View {
        ChatView(chat: chat)
    }
            
    @StateObject var chat = Chat(title: "Mock Chat", chatAI: MockChatAI())
}

struct ChatView: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                List {
                    ForEach(chat.messages) { message in
                        MessageView(message: message)
                            .id(message.id)
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
                    
                    Color.clear
                        .frame(height: 30)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .safeAreaPadding([.top, .bottom], verticalSpacing / 2)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .onChange(of: chat.scrollDestinationMessageID) {
                    if let id = chat.scrollDestinationMessageID {
                        withAnimation {
                            scrollView.scrollTo(id, anchor: .top)
                            chat.scrollDestinationMessageID = nil
                        }
                    }
                }
            }
            .animation(.default, value: chat.messages)

            InputView(chat: chat)
        }
        .background(Color.dynamic(.aiOSLevel0))
        .navigationTitle(chat.title)
    }
    
    var verticalSpacing: CGFloat { 16 }
    
    @ObservedObject var chat: Chat
}
