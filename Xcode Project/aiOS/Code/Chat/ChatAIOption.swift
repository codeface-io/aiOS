import SwiftAI

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
