import SwiftUI

struct MessageView: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if message.isFromAssistant {
                Text(message.content.suffix(1))
            } else {
                Image(systemName: "questionmark.bubble")
                    .foregroundStyle(.secondary)
            }
            
            Text(message.content.dropLast(message.isFromAssistant ? 1 : 0))
                .lineLimit(nil)
                .foregroundStyle(message.isFromAssistant ? .primary : .secondary)
        }
    }
    
    let message: Message
}
