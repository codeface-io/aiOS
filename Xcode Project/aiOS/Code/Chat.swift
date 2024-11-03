import SwiftAI
import Foundation
import SwiftyToolz

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
            "Keep your answers short and to the point. End all your answers with exactly one fitting emoji, so that one emoji is always the very last character."
        )
        
        Task {
            do {
                let answer = try await chatBot.complete(chat: messages + extraPrompt)
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
    
    @Published var messages = [Message]()
    
    init(title: String, chatBot: ChatAccess) {
        self.title = title
        self.chatBot = chatBot
    }
    
    private let chatBot: ChatAccess
    
    let title: String
    let id = UUID()
}
