import SwiftAI
import SwiftUI

#Preview {
    NavigationStack {
        ChatView(chat: Chat(title: "Test Chat",
                            chatBotType: Grok.self,
                            chatBotKey: .xAI))
    }
}

struct ChatView: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                List {
                    if chat.messages.isEmpty {
                        MessageView(message: Message("Write a message to start the conversation.😊",
                                                     role: .assistant))
                    } else {
                        ForEach(chat.messages) { message in
                            MessageView(message: message)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        UIPasteboard.general.string = message.content
                                    } label: {
                                        Label("Copy", systemImage: "doc.on.doc")
                                    }
                                }
                                .id(message.id)
                        }
                        .onDelete(perform: chat.deleteItems)
                    }
                }
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
                    .background(Color(.secondarySystemBackground))
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
        }
        .navigationTitle(chat.title)
    }
    
    @ObservedObject var chat: Chat
}
