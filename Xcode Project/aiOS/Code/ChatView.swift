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
                            .listRowInsets(
                                EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .swipeActions(edge: .leading) {
                                Button {
//                                    UIPasteboard.general.string = message.content
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                            }
                    }
                    .onDelete(perform: chat.deleteItems)
                    
                    Spacer()
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .frame(height: 30)
                }
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

            HStack(alignment: .bottom) {
                TextEditor(text: $chat.input)
                    .autocorrectionDisabled()
                    .onSubmit(chat.submit)
                    .scrollClipDisabled()
                    .scrollContentBackground(.hidden)
                    .padding(5)
                    .background(Color.dynamic(.aiOSLevel1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Image(systemName: "paperplane.fill")
                    .imageScale(.large)
                    .padding()
                    .frame(maxHeight: .infinity)
                    .background(Color.dynamic(.aiOSLevel3))
                    .foregroundStyle(chat.input.isEmpty ? .secondary : .primary)
                    .onTapGesture {
                        chat.submit()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()
            .frame(height: 100)
            .background(Color.dynamic(.aiOSLevel2))
        }
        .background(Color.dynamic(.aiOSLevel0))
        .navigationTitle(chat.title)
    }
    
    @ObservedObject var chat: Chat
}
