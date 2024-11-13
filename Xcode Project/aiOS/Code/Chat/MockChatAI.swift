import SwiftAI

struct MockChatAI: ChatAI {
    func complete(chat: [SwiftAI.Message]) async throws -> SwiftAI.Message {
        try? await Task.sleep(for: .milliseconds(100))
        return .init(responses.randomElement() ?? "Something went wrong 😅",
                     role: .assistant)
    }
}

private let responses = [
    "Ok! 👍",
    "This is a medium length response that could be used for testing the chat interface. Hope it helps! 😊",
    "Here's a longer response that contains multiple sentences. This helps test how the UI handles longer messages with different amounts of text. It's important to test various lengths to ensure everything displays correctly and scrolls properly. Have a great day! 🌟",
    "Testing... 🤖",
    "Thanks for your message! Let me help you with that. 💫"
]
