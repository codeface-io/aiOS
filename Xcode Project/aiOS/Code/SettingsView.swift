import SwiftUI
import Combine
import Foundation
import SwiftyToolz

#Preview("SettingsView") {
    SettingsView()
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List(API.Identifier.allCases) { api in
                Section(api.displayName) {
                    SecureField("Enter \(api.displayName) API Key",
                                text: keyBinding(for: api))
                }
            }
            .navigationTitle("API Keys")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }

    private func keyBinding(for api: API.Identifier) -> Binding<String> {
        Binding(
            get: {
                @Keychain(.apiKeys) var storedKeys: [API.Key]?
                return (storedKeys?.first { $0.apiIdentifier == api }?.value) ?? ""
            },
            set: { newValue in
                @Keychain(.apiKeys) var storedKeys: [API.Key]?
                
                if newValue.isEmpty {
                    storedKeys?.removeAll { $0.apiIdentifier == api }
                } else if let originalIndex = storedKeys?.firstIndex(where: { $0.apiIdentifier == api }),
                          let originalKey = storedKeys?[originalIndex] {
                    if let updatedKey = API.Key(
                        newValue,
                        apiIdentifierValue: api.rawValue,
                        name: originalKey.name,
                        description: originalKey.description,
                        id: originalKey.id
                    ) {
                        storedKeys?[originalIndex] = updatedKey
                    }
                } else {
                    if let newKey = API.Key(
                        newValue,
                        apiIdentifierValue: api.rawValue
                    ) {
                        storedKeys = (storedKeys ?? []) + newKey
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
