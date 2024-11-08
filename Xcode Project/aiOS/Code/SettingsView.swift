import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Option 1")
                Text("Option 2")
                Text("Option 3")
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            #if os(iOS)
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
            #endif
        }
    }
    
    @Environment(\.dismiss) private var dismiss
}
