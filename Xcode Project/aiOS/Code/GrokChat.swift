import SwiftAI
import Foundation

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
