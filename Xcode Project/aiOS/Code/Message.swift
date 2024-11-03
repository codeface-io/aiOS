import Foundation

struct Message: Equatable, Identifiable {
    init(_ content: String, isFromAssistant: Bool = false) {
        self.content = content
        self.isFromAssistant = isFromAssistant
    }
    
    let id = UUID()
    let content: String
    let isFromAssistant: Bool
}
