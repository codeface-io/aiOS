import SwiftAI
import FoundationToolz
import Combine
import Foundation
import SwiftyToolz

extension Chat {
    static var mock: Chat {
        Chat(title: "Mock Chat")
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
        scrollDestinationMessageID = message.id
    }

    @Published var scrollDestinationMessageID: UUID?
    @Published var input = ""

    func deleteItems(at offsets: IndexSet) {
        messages.remove(atOffsets: offsets)
    }
    
    convenience init(loadingFrom file: URL, chatAIOption: ChatAIOption) throws {
        let dto: ChatDTO = try {
            if FileManager.default.itemExists(file) {
                return try ChatDTO(fromJSONFile: file)
            } else {
                let newDTO = ChatDTO(title: "New Chat", messages: [.conversationStarter])
                try newDTO.save(to: file)
                return newDTO
            }
        }()
        
        self.init(title: dto.title,
                  messages: dto.messages,
                  file: file,
                  chatAIOption: chatAIOption)
    }

    init(title: String,
         messages: [Message] = [.conversationStarter],
         file: URL? = nil,
         chatAIOption: ChatAIOption = .mock) {
        self.title = title
        self.messages = messages
        self.file = file
        self.chatAIOption = chatAIOption
        
        observeForPersistence()
    }
    
    // MARK: - Persistence
    
    private func observeForPersistence() {
        guard file != nil else { return }
        
        observations += $messages
            .combineLatest($title)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.save()
            }
    }
    
    private var observations = Set<AnyCancellable>()
    
    func save() {
        guard let file else { return }
        
        Task {
            do {
                try makeDTO().save(to: file)
            } catch {
                log(error: error.readable.message)
            }
        }
    }

    func makeDTO() -> ChatDTO {
        .init(title: title, messages: messages)
    }
    
    let file: URL?
    
    // MARK: - Basic Data
    
    @Published var messages = [Message]()

    @Published var chatAIOption: ChatAIOption

    @Published var title: String
    let id = UUID()
}

extension Message {
    static var conversationStarter: Message {
        Message("Write a message to start the conversation.😊",
                role: .assistant)
    }
}
