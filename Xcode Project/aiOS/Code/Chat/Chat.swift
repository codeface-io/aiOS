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
        append(Message(input))
        input = ""

        let extraPrompt = Message( // a bit of prompt engineering :)
            "Keep your answers short and to the point.",
            role: .system
        )

        Task {
            do {
                let answer = try await chatAIOption.chatAI.complete(chat: messages + extraPrompt)
                append(answer)
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

    @Published var messages = [
        Message("Write a message to start the conversation.😊",
                role: .assistant)
    ]

    init(title: String, chatAIOption: ChatAIOption) {
        self.title = title
        self.chatAIOption = chatAIOption
    }

    @Published var chatAIOption: ChatAIOption

    let title: String
    let id = UUID()
}

struct ChatAIOption {
    static var mock: ChatAIOption {
        .init(chatAI: MockChatAI(), displayName: "Mock AI")
    }
    
    let chatAI: ChatAI
    let displayName: String
}
