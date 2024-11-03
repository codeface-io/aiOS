import SwiftUI
import SwiftAI

#Preview {
    AIOSAppView()
}

struct AIOSAppView: View {
    var body: some View {
        NavigationSplitView {
            List(chats, selection: $selectedChat) { chat in
                NavigationLink(value: chat) {
                    Label(chat.title,
                          systemImage: "bubble.left.and.bubble.right")
                }
            }
            .navigationTitle("Chats")
        } detail: {
            if let selectedChat {
                ChatView(chat: selectedChat)
            }
        }
    }
     
    @State var selectedChat: GrokChat?
    
    @State var chats = [
        GrokChat(title: "Chat with Grok",
                 apiKey: .xAI)
    ]
}

#Preview {
    NavigationStack {
        ChatView(chat: GrokChat(title: "Test Chat", apiKey: AuthenticationKey("")))
    }
}

struct ChatView: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                List {
                    if chat.messages.isEmpty {
                        MessageView(message: Message("Write a message to start the conversation.😊",
                                                     isFromAssistant: true))
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
    
    @ObservedObject var chat: GrokChat
}

struct MessageView: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if message.isFromAssistant {
                Text(message.content.suffix(1))
            } else {
                Image(systemName: "questionmark.bubble")
                    .foregroundStyle(.secondary)
            }
            
            Text(message.content.dropLast(message.isFromAssistant ? 1 : 0))
                .lineLimit(nil)
                .foregroundStyle(message.isFromAssistant ? .primary : .secondary)
        }
    }
    
    let message: Message
}

class GrokChat: ObservableObject, Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GrokChat, rhs: GrokChat) -> Bool {
        lhs.id == rhs.id
    }
    
    @MainActor
    func submit() {
        // clear input field
        let userMessageContent = input
        input = ""
        
        // add user message to chat
        append(Message(userMessageContent))
        
        // prepare xAI messages to be sent
        var xAIMessages = messages.map { message in
            XAI.Message(message.content,
                        role: message.isFromAssistant ? .assistant : .user)
        }
        
        xAIMessages.append(.init( // a bit of prompt engineering :)
            "Keep your answers short and to the point. End all your answers with exactly one fitting emoji, so that one emoji is always the very last character.",
            role: .system
        ))
        
        Task {
            do {
                // send xAI messages
                let response = try await XAI.ChatCompletions.post(.init(xAIMessages),
                                                                  authenticationKey: apiKey)
                
                // retrieve returned xAI message
                guard
                    let grokXAIMessage = response.choices.first?.message,
                    grokXAIMessage.role == .assistant
                else {
                    return
                }
                
                // turn it into a regular message
                let grokMessage = Message(grokXAIMessage.content ?? grokXAIMessage.refusal ?? "",
                                          isFromAssistant: true)
                
                // add grok's response message to the chat
                append(grokMessage)
            } catch {
                print(error)
            }
        }
    }
    
    private func append(_ message: Message) {
        messages.append(message)
        scrollDestinationMessageID = message.id
    }
    
    @Published var scrollDestinationMessageID: UUID?
    
    @Published var input = ""
    
    func deleteItems(at offsets: IndexSet) {
        messages.remove(atOffsets: offsets)
    }
    
    @Published var messages = [Message]()
    
    init(title: String, apiKey: AuthenticationKey) {
        self.title = title
        self.apiKey = apiKey
    }
    
    let apiKey: AuthenticationKey
    let title: String
    let id = UUID()
}

struct Message: Equatable, Identifiable {
    init(_ content: String, isFromAssistant: Bool = false) {
        self.content = content
        self.isFromAssistant = isFromAssistant
    }
    
    let id = UUID()
    let content: String
    let isFromAssistant: Bool
}
