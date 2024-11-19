import SwiftUI

struct ChatListView: View {
    var body: some View {
        List(selection: $chatList.selectedChat) {
            Section(header: Text("iCloud")) {
                ForEach(chatList.iCloudChats) { chat in
                    NavigationLink(value: chat) {
                        ChatListItemView(chat: chat)
                    }
#if os(macOS)
                    .swipeActions(edge: .trailing) {
                        Button {
                            delete(iCloudChat: chat)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
#endif
                }
#if !os(macOS)
                .onDelete { chatList.removeICloudChats(at: $0) }
#endif
            }
            
            Section(header: Text(deviceName)) {
                ForEach(chatList.localChats) { chat in
                    NavigationLink(value: chat) {
                        ChatListItemView(chat: chat)
                    }
#if os(macOS)
                    .swipeActions(edge: .trailing) {
                        Button {
                            delete(localChat: chat)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
#endif
                }
#if !os(macOS)
                .onDelete { chatList.removeLocalChats(at: $0) }
#endif
            }
        }
#if !os(macOS)
        .animation(.default, value: chatList.localChats) // it just looks broken on macOS
#endif
        .onAppear {
            chatList.checkICloudAvailability()
        }
        .navigationTitle("Chats")
    }
    
    func delete(localChat: Chat) {
        if chatList.selectedChat === localChat {
            chatList.selectedChat = nil
        }
        
        if let index = chatList.localChats.firstIndex(where: { $0 === localChat }) {
            chatList.removeLocalChats(at: [index])
        }
    }
    
    func delete(iCloudChat: Chat) {
        if chatList.selectedChat === iCloudChat {
            chatList.selectedChat = nil
        }
        
        if let index = chatList.iCloudChats.firstIndex(where: { $0 === iCloudChat }) {
            chatList.removeICloudChats(at: [index])
        }
    }
    
    @ObservedObject var chatList: ChatList
}

#if os(macOS)
var deviceName: String { "This Mac" }
#else
import UIKit
var deviceName: String { UIDevice.current.name }
#endif
