import SwiftUI
import SwiftAI

#Preview {
    ScrollView {
        LazyVStack(spacing: 18) {
            MessageView(message: .init("equzrfg ouqdzf vuodaf v",
                                       role: .user))
            
            MessageView(message: .init("equzrfg ouqdzf vuodaf v 😊",
                                       role: .assistant))
            
            MessageView(message: .init("equzrfg ouqdzf vuodaf v",
                                       role: .user))
            
            MessageView(message: .init("equzrfg ouqdzf vuodaf 😊",
                                       role: .assistant))
        }
        .padding()
    }
    .background(Color(.systemBackground))
}

struct MessageView: View {
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            HStack(alignment: .firstTextBaseline) {
                if !isUser {
                    Text(message.content.suffix(1))
                        .background(Color(.secondarySystemBackground))
                }
                
                Text(message.content.dropLast(!isUser ? 1 : 0))
                    .lineLimit(nil)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if !isUser { Spacer() }
        }
        .padding(.leading, isUser ? 20 : 0)
        .padding(.trailing, isUser ? 0 : 20)
        .foregroundStyle(isUser ? .secondary : .primary)
    }
    
    var isUser: Bool { message.role == .user }
    
    let message: Message
}
