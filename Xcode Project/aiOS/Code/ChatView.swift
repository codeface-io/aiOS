import SwiftAI
import SwiftUI

#Preview {
    NavigationStack {
        ChatView(chat: Chat(title: "Test Chat",
                            chatAI: MockChatAI()))
    }
}

struct MockChatAI: ChatAI {
    func complete(chat: [SwiftAI.Message]) async throws -> SwiftAI.Message {
        .init("This is an auto generated mock answer for testing.😎",
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
                            .listRowInsets(nil)
                            .listRowSeparator(.hidden)
                            .listRowSpacing(0)
                            .swipeActions(edge: .leading) {
                                Button {
                                    UIPasteboard.general.string = message.content
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                            }
                    }
                    .onDelete(perform: chat.deleteItems)
                }
                .listStyle(.plain)
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
            
            HStack(spacing: 0) {
                TextEditor(text: $chat.input)
                    .autocorrectionDisabled()
                    .onSubmit(chat.submit)
                    .scrollClipDisabled()
                    .scrollContentBackground(.hidden)
                    .padding(5)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding([.leading, .vertical])
                
                Button {
                    chat.submit()
                } label: {
                    VStack {
                        Spacer()
                        
                        Image(systemName: "paperplane.fill")
                            .imageScale(.large)
                            .padding()
                    }
                }
                .disabled(chat.input.isEmpty)
            }
            .frame(height: 100)
            .background(Color(.secondarySystemBackground))
        }
        .background(Color(.systemBackground))
        .navigationTitle(chat.title)
    }
    
    @ObservedObject var chat: Chat
}
