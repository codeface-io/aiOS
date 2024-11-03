import SwiftUI
import SwiftAI

struct MessageView: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if message.role == .assistant {
                Text(message.content.suffix(1))
            } else {
                Image(systemName: "questionmark.bubble")
            }
            
            Text(message.content.dropLast(message.role == .assistant ? 1 : 0))
                .lineLimit(nil)
                
        }
        .foregroundStyle(message.role == .assistant ? .primary : .secondary)
    }
    
    let message: Message
}
