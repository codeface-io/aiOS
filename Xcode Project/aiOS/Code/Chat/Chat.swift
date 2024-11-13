import SwiftAI
import Foundation
import SwiftyToolz

extension Chat {
    static var mock: Chat {
        Chat(title: "Mock Chat", chatAIOption: .mock)
    }
}

class Chat: ObservableObject, Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }

    @MainActor
    func submit() {
        guard hasContentToSend else { return }
        
        if !input.isEmpty {
            append(Message(input))
            input = ""
        }

        isLoading = true
        
        let systemPrompt = "Keep your answers short and to the point."

        Task { @MainActor in
            do {
                let answer = try await chatAIOption.chatAI.complete(chat: messages,
                                                                    systemPrompt: systemPrompt)
                append(answer)
                isLoading = false
            } catch {
                print(error)
                isLoading = false
            }
        }
    }
    
    var hasContentToSend: Bool {
        !messages.isEmpty || !input.isEmpty
    }
    
    @Published var isLoading = false

    private func append(_ message: Message) {
        messages.append(message)
        scrollDestinationMessageID = message.id
    }

    @Published var scrollDestinationMessageID: UUID?
    @Published var input = ""

    func deleteItems(at offsets: IndexSet) {
        messages.remove(atOffsets: offsets)
    }

    @Published var messages = [
        Message("Write a message to start the conversation.😊",
                role: .assistant)
    ]

    init(title: String, chatAIOption: ChatAIOption) {
        self.title = title
        self.chatAIOption = chatAIOption
    }

    @Published var chatAIOption: ChatAIOption

    @Published var title: String
    let id = UUID()
}

struct ChatAIOption: Hashable, Identifiable {
    static func == (lhs: ChatAIOption, rhs: ChatAIOption) -> Bool {
        lhs.displayName == rhs.displayName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
    }
    
    var id: String { displayName }
    
    static var mock: ChatAIOption {
        .init(chatAI: MockChatAI(), displayName: "Mock AI")
    }
    
    let chatAI: ChatAI
    let displayName: String
}
