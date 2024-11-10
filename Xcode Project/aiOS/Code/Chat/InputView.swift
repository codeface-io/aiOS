import SwiftUI

#Preview {
    InputView(chat: .mock)
}

struct InputPreview: View {
    var body: some View {
        InputView(chat: chat)
    }
    
    @StateObject var chat = Chat.mock
}

struct InputView: View {
    var body: some View {
        HStack {
            TextEditor(text: $chat.input)
                .autocorrectionDisabled()
                .onSubmit(chat.submit)
                .scrollClipDisabled()
                .scrollContentBackground(.hidden)
                .padding(5)
                .background(Color.dynamic(.aiOSLevel1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Image(systemName: "paperplane.fill")
                .imageScale(.large)
                .padding()
                .frame(maxHeight: .infinity)
                .background(Color.dynamic(.aiOSLevel3))
                .foregroundStyle(chat.input.isEmpty ? .secondary : .primary)
                .onTapGesture {
                    chat.submit()
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .opacity(chat.isLoading ? 0 : (chat.input.isEmpty ? 0.5 : 1))
                .overlay {
                    if chat.isLoading {
                        ProgressView()
                    }
                }
        }
        .padding()
        .frame(height: 100)
        .background(Color.dynamic(.aiOSLevel2))
    }
    
    @ObservedObject var chat: Chat
}
