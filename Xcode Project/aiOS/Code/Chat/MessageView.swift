import SwiftUI
import SwiftAI

#Preview {
    NavigationStack {
        List {
            ForEach(0 ..< 10) { _ in
                MessageView(message: .init("equzrfg ouqdzf vuodaf v",
                                           role: .user))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding()
                
                MessageView(message: .init("equzrfg ouqdzf vuodaf v 😊",
                                           role: .assistant))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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
        // the id must be inside here and not outside in the List view so that programmatic scrolling works on macOS. this might actually be a SwiftUI bug.
        .id(message.id)
    }
    
    var isUser: Bool { message.role == .user }
    
    let message: Message
}
