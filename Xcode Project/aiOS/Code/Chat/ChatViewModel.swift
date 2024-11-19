import SwiftAI
import FoundationToolz
import Foundation
import SwiftyToolz

extension ChatViewModel {
    static var mock: ChatViewModel {
        ChatViewModel(file: try! FileService.documentsFolder, title: "Mock Chat", chatAIOption: .mock)
    }
}

class ChatViewModel: ObservableObject, Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ChatViewModel, rhs: ChatViewModel) -> Bool {
        lhs.id == rhs.id
    }

    @MainActor
    func submit() async throws {
        guard !isLoading, hasContentToSend else { return }
        
        isLoading = true
        
        if !input.isEmpty {
            append(Message(input))
            input = ""
        }

        let systemPrompt = "Keep your answers short and to the point."

        do {
            let answer = try await chatAIOption.chatAI.complete(chat: messages,
                                                                systemPrompt: systemPrompt)
            
            append(answer)
            isLoading = false
        } catch {
            isLoading = false
            throw error
        }
    }
    
    var hasContentToSend: Bool {
        !messages.isEmpty || !input.isEmpty
    }
    
    @Published var isLoading = false

    private func append(_ message: Message) {
        messages.append(message)
        
        do {
            try messages.save(to: file)
        } catch {
            log(error: error.readable.message)
        }
        
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

    init(file: URL, title: String, chatAIOption: ChatAIOption) {
        self.file = file
        self.title = title
        self.chatAIOption = chatAIOption
        
        do {
            messages = try [Message](fromJSONFile: file)
        } catch {
            log(error: error.readable.message)
        }
    }

    @Published var chatAIOption: ChatAIOption

    @Published var title: String
    let id = UUID()
    
    let file: URL
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
