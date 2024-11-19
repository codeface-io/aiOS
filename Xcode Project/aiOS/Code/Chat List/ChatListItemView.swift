import SwiftUI

struct ChatListItemView: View {
    var body: some View {
        Label {
            if isEditing {
                TextField("Chat Title", text: $chat.title) {
                    isEditing = false
                }
                .focused($fieldIsFocused)
                .onChange(of: fieldIsFocused) { _, isFocused in
                    if !isFocused {
                        isEditing = false
                    }
                }
            } else {
                Text(chat.title)
            }
        } icon: {
            Image(systemName: "bubble.left.and.bubble.right")
        }
        .swipeActions(edge: .leading) {
            Button {
                startEditing()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
        }
        .contextMenu {
            Button {
                startEditing()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            #if !os(macOS)
            Button {
                editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
            } label: {
                Label(editMode?.wrappedValue == .active ? "Done Editing List" : "Edit List",
                      systemImage: editMode?.wrappedValue == .active ? "checkmark" : "arrow.up.arrow.down")
            }
            #endif
        }
    }

    #if !os(macOS)
    @Environment(\.editMode) private var editMode
    #endif
    
    func startEditing() {
        isEditing = true
        fieldIsFocused = true
    }
    
    @FocusState var fieldIsFocused: Bool
    @State private var isEditing = false
    
    @ObservedObject var chat: Chat
}
