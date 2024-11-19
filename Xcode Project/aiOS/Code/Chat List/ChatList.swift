import SwiftAI
import Foundation
import SwiftyToolz

@MainActor
class ChatList: ObservableObject {
    func addNewChat() {
        guard let option = APIKeys.shared.chatAIOptions.first else { return }

        do {
            let title = Date().utcString
            let newURL = try FileService.documentsFolder.appending(component: title + ".aios")
            
            let newChat = try Chat(loadingFrom: newURL, chatAIOption: option)
            
            localChats.insert(newChat, at: 0)
            
            Task { @MainActor in
                self.selectedChat = newChat
            }
        } catch {
            log(error: error.readable.message)
        }
    }
    
    func removeChats(at offsets: IndexSet) {
        // first delete the chat files
        let filesToRemove = offsets.compactMap { localChats[$0].file }
        
        for file in filesToRemove {
            do {
                try FileManager.default.removeItem(at: file)
            } catch {
                log(error: error.readable.message)
            }
        }
        
        // then remove that chat view models
        localChats.remove(atOffsets: offsets)
    }
    
    func loadLocalChats() {
        guard let option = APIKeys.shared.chatAIOptions.first else { return }
        
        do {
            let files = try FileService.contentsOfDocumentsFolder()
                .filter {
                    $0.lastPathComponent.hasSuffix(".aios")
                }

            localChats = files.compactMap {
                do {
                    return try Chat(loadingFrom: $0, chatAIOption: option)
                } catch {
                    log(error: error.readable.message)
                    return nil
                }
            }
        } catch {
            log(error: error.readable.message)
        }
    }
    
    @Published var selectedChat: Chat?
    @Published private(set) var iCloudChats = [Chat]()
    @Published private(set) var localChats = [Chat]()
}
