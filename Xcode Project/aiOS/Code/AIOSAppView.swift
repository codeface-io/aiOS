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
            List(chat.messages, id: \.content) { message in
                Label(message.content,
                      systemImage: message.isFromAssistant ? "checkmark.bubble.fill" : "questionmark.bubble")
            }
            .animation(.default, value: chat.messages)
            
            HStack {
                TextField("Type here",
                          text: $chat.input,
                          prompt: Text("Type here"))
                .lineLimit(nil)
                .onSubmit {
                    chat.submit()
                }
                .padding(.leading)
                
                Button {
                    chat.submit()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .imageScale(.large)
                        .padding()
                }
                .disabled(chat.input.isEmpty)
            }
        }
        .navigationTitle(chat.title)
    }
    
    @ObservedObject var chat: GrokChat
}

class GrokChat: ObservableObject, Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GrokChat, rhs: GrokChat) -> Bool {
        lhs.id == rhs.id
    }
    
    func submit() {
        messages.append(.init(content: input,
                              isFromAssistant: false))
        input = ""
        
        let xAIMessages = messages.map { message in
            XAI.Message(message.content,
                        role: message.isFromAssistant ? .assistant : .user)
        }
        
        Task {
            do {
                let response = try await XAI.ChatCompletions.post(.init(xAIMessages),
                                                                  authenticationKey: apiKey)
                
                if let xAIMessage = response.choices.first?.message {
                    messages.append(.init(
                        content: xAIMessage.content ?? xAIMessage.refusal ?? "",
                        isFromAssistant: xAIMessage.role == .assistant
                    ))
                }
            } catch {
                print(error)
            }
        }
    }
    
    @Published var input = ""
    
    @Published var messages = [Message]()
    
    init(title: String, apiKey: AuthenticationKey) {
        self.title = title
        self.apiKey = apiKey
    }
    
    let apiKey: AuthenticationKey
    let title: String
    let id = UUID()
}

struct Message: Equatable {
    let content: String
    let isFromAssistant: Bool
}
