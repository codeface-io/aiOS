import SwiftAI
import Foundation
import SwiftyToolz

@MainActor
class ChatList: ObservableObject {
    init() {
        loadLocalChats()
        loadICloudChats()
    }
    
    // MARK: - Add New Chat
    
    func addNewChat() {
        guard let option = APIKeys.shared.chatAIOptions.first else { return }
        
        let fileName = Date().utcString + ".aios"

        do {
            let chat: Chat = try {
                if let iCloudFolder = FileService.iCloudDocumentsFolder {
                    let newURL = iCloudFolder.appending(component: fileName)
                    let newChat = try Chat(loadingFrom: newURL, chatAIOption: option)
                    iCloudChats.insert(newChat, at: 0)
                    return newChat
                } else {
                    let newURL = try FileService.documentsFolder.appending(component: fileName)
                    let newChat = try Chat(loadingFrom: newURL, chatAIOption: option)
                    localChats.insert(newChat, at: 0)
                    return newChat
                }
            }()
            
            Task { @MainActor in
                self.selectedChat = chat
            }
        } catch {
            log(error: error.readable.message)
        }
    }
    
    // MARK: - Selected Chat
    
    @Published var selectedChat: Chat?
    
    // MARK: - iCloud Chats
    
    func checkICloudAvailability() {
        if iCloudChats.isEmpty && FileService.isICloudDriveEnabledOnDevice {
            loadICloudChats()
        }
    }
    
    func removeICloudChats(at offsets: IndexSet) {
        // first delete the chat files
        let filesToRemove = offsets.compactMap { iCloudChats[$0].file }
        
        for file in filesToRemove {
            do {
                try FileManager.default.removeItem(at: file)
            } catch {
                log(error: error.readable.message)
            }
        }
        
        // then remove that chat view models
        iCloudChats.remove(atOffsets: offsets)
    }
    
    func loadICloudChats() {
        guard let option = APIKeys.shared.chatAIOptions.first,
              FileService.isICloudDriveEnabledOnDevice else { return }
        
        do {
            iCloudChats = loadChats(fromFiles: try FileService.contentsOfICloudDocumentsFolder(),
                                    using: option)
        } catch {
            log(error: error.readable.message)
        }
    }
    
    @Published private(set) var iCloudChats = [Chat]()
    
    // MARK: - Local Chats
    
    func removeLocalChats(at offsets: IndexSet) {
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
            localChats = loadChats(fromFiles: try FileService.contentsOfDocumentsFolder(),
                                   using: option)
        } catch {
            log(error: error.readable.message)
        }
    }
    
    @Published private(set) var localChats = [Chat]()
}

private func loadChats(fromFiles files: [URL], using option: ChatAIOption) -> [Chat] {
    files
        .filter { $0.lastPathComponent.hasSuffix(".aios") }
        .compactMap {
            do {
                return try Chat(loadingFrom: $0, chatAIOption: option)
            } catch {
                log(error: error.readable.message + "\nfile: " + $0.absoluteString)
                return nil
            }
        }
}
