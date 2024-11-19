import SwiftAI
import Foundation
import SwiftyToolz

@MainActor
class AIOSAppViewModel: ObservableObject {
    func addNewChat() {
        guard let option = APIKeys.shared.chatAIOptions.first else { return }

        do {
            let title = Date().utcString
            let newURL = try FileService.documentsFolder.appending(component: title + ".aios")
            
            let newChat = try ChatViewModel(loadingFrom: newURL, chatAIOption: option)
            
            chats.insert(newChat, at: 0)
            
            Task { @MainActor in
                self.selectedChat = newChat
            }
        } catch {
            log(error: error.readable.message)
        }
    }
    
    @Published var showsSettings = false
    
    func loadDocuments() {
        guard let option = APIKeys.shared.chatAIOptions.first else { return }
        
        do {
            let files = try FileService.contentsOfDocumentsFolder()
                .filter {
                    $0.lastPathComponent.hasSuffix(".aios")
                }

            chats = files.compactMap {
                do {
                    return try ChatViewModel(loadingFrom: $0, chatAIOption: option)
                } catch {
                    log(error: error.readable.message)
                    return nil
                }
            }
        } catch {
            log(error: error.readable.message)
        }
    }
    
    
    @Published var selectedChat: ChatViewModel?
    @Published var chats = [ChatViewModel]()
}
