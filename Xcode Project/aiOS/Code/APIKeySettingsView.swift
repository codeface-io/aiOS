import SwiftUI
import Combine
import Foundation
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
                @Keychain(.apiKeys) var keys: [API.Key]?
                return (keys?.first { $0.apiIdentifier == api }?.value) ?? ""
            },
            set: { newValue in
                @Keychain(.apiKeys) var keys: [API.Key]?
                
                if newValue.isEmpty {
                    keys?.removeAll { $0.apiIdentifier == api }
                } else if let originalIndex = keys?.firstIndex(where: { $0.apiIdentifier == api }),
                          let originalKey = keys?[originalIndex] {
                    if let updatedKey = API.Key(
                        newValue,
                        apiIdentifierValue: api.rawValue,
                        name: originalKey.name,
                        description: originalKey.description,
                        id: originalKey.id
                    ) {
                        keys?[originalIndex] = updatedKey
                    }
                } else {
                    if let newKey = API.Key(
                        newValue,
                        apiIdentifierValue: api.rawValue
                    ) {
                        keys = (keys ?? []) + newKey
                    }
                }
            }
        )
    }
    
    
    @Environment(\.dismiss) private var dismiss
}

extension KeychainItemID {
    static let apiKeys = KeychainItemID("apiKeys")
}
