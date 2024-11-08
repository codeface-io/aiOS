import SwiftUI
import SwiftAI

#Preview {
    NavigationStack {
        List {
            ForEach(0 ..< 10) { _ in
                MessageView(message: .init("equzrfg ouqdzf vuodaf v",
                                           role: .user))
                .listRowInsets(
                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
#if os(iOS)
                .listRowSpacing(0)
#endif
                
                MessageView(message: .init("equzrfg ouqdzf vuodaf v 😊",
                                           role: .assistant))
                .listRowInsets(
                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
#if os(iOS)
                .listRowSpacing(0)
#endif
            }
        }   
        .background(Color.dynamic(.aiOSLevel0))
    }
}

struct MessageView: View {
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            HStack(alignment: .firstTextBaseline) {
                if !isUser {
                    Text(message.content.suffix(1))
                }
                
                Text(message.content.dropLast(!isUser ? 1 : 0))
                    .lineLimit(nil)
            }
            .padding()
            .background(Color.dynamic(.aiOSLevel3))
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
