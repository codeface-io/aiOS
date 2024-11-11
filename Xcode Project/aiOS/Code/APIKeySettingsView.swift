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
            get: {
                (API.keys?.first { $0.apiIdentifier == api }?.value) ?? ""
            },
            set: { newValue in
                if newValue.isEmpty {
                    API.keys?.removeAll { $0.apiIdentifier == api }
                } else if let originalIndex = API.keys?.firstIndex(where: { $0.apiIdentifier == api }),
                          let originalKey = API.keys?[originalIndex] {
                    if let updatedKey = API.Key(
                        newValue,
                        apiIdentifierValue: api.rawValue,
                        name: originalKey.name,
                        description: originalKey.description,
                        id: originalKey.id
                    ) {
                        API.keys?[originalIndex] = updatedKey
                    }
                } else {
                    if let newKey = API.Key(
                        newValue,
                        apiIdentifierValue: api.rawValue
                    ) {
                        API.keys = (API.keys ?? []) + newKey
                    }
                }
            }
        )
    }
    
    
    @Environment(\.dismiss) private var dismiss
}
