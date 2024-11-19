import SwiftUI
import SwiftyToolz

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
                .onSubmit(submit)
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
                .foregroundStyle(chat.hasContentToSend ? .primary : .secondary)
                .onTapGesture { submit() }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .opacity(chat.isLoading ? 0 : (chat.hasContentToSend ? 1 : 0.5))
                .overlay {
                    if chat.isLoading {
                        ProgressView()
                    }
                }
        }
        .padding()
        .frame(height: 100)
        .background(Color.dynamic(.aiOSLevel2))
        .alert("Request Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text("Make sure you're online and the API key is valid.")
        }
    }
    
    // MARK: - Submit and Handle Submission Error
    
    func submit() {
        Task {
            do {
                try await chat.submit()
            } catch {
                log(error: error.readable.message)
                showError = true
            }
        }
    }
    
    @State private var showError = false
    
    // MARK: - Basics
    
    @ObservedObject var chat: Chat
}
