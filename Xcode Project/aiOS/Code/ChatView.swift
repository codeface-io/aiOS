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
            
    @StateObject var chat = Chat(title: "Test Chat",
                                 chatAI: MockChatAI())
}

struct MockChatAI: ChatAI {
    func complete(chat: [SwiftAI.Message]) async throws -> SwiftAI.Message {
        let responses = [
            "Ok! 👍",
            "This is a medium length response that could be used for testing the chat interface. Hope it helps! 😊",
            "Here's a longer response that contains multiple sentences. This helps test how the UI handles longer messages with different amounts of text. It's important to test various lengths to ensure everything displays correctly and scrolls properly. Have a great day! 🌟",
            "Testing... 🤖",
            "Thanks for your message! Let me help you with that. 💫"
        ]
        
        return .init(responses.randomElement() ?? "Something went wrong 😅",
                     role: .assistant)
    }
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
//                                    UIPasteboard.general.string = message.content
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
