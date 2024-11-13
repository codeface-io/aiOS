import SwiftUI
import SwiftAI
import FoundationToolz
import SwiftyToolz

#Preview {
    APIKeySettingsView()
}

struct APIKeySettingsView: View {
    var body: some View {
        NavigationStack {
            List(API.Identifier.allCases) { api in
                Section(api.displayName) {
                    SecureField("Enter \(api.displayName) API Key",
                                text: keyBinding(for: api))
                }
            }
            .navigationTitle("API Keys")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }

    private func keyBinding(for api: API.Identifier) -> Binding<String> {
        Binding(
            get: { APIKeys.shared.keyValue(for: api) ?? "" },
            set: { APIKeys.shared.set(keyValue: $0, for: api) }
        )
    }
    
    @Environment(\.dismiss) private var dismiss
}
