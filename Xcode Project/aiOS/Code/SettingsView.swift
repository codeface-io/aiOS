import SwiftUI
import Combine
import Foundation

#Preview("SettingsView") {
    SettingsView()
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List(ProviderIdentifier.allCases) { provider in
                Section(provider.displayName) {
                    SecureField("Enter \(provider.displayName) API Key",
                                text: keyBinding(for: provider))
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

    private func keyBinding(for provider: ProviderIdentifier) -> Binding<String> {
        Binding(
            get: {
                keyStore.keys.first { $0.providerIdentifierValue == provider.rawValue }?.keyValue ?? ""
            },
            set: { newValue in
                if newValue.isEmpty {
                    keyStore.keys.removeAll {
                        $0.providerIdentifierValue == provider.rawValue
                    }
                    
                    return
                }
                
                if let originalKey = keyStore.keys.first(where: {
                    $0.providerIdentifierValue == provider.rawValue
                }) {
                    if let updatedKey = AuthenticationKeyEntry(
                        newValue,
                        providerIdentifierValue: provider.rawValue,
                        name: originalKey.name,
                        description: originalKey.description,
                        id: originalKey.id
                    ) {
                        keyStore.update(updatedKey)
                    }
                } else {
                    if let newKey = AuthenticationKeyEntry(
                        newValue,
                        providerIdentifierValue: provider.rawValue
                    ) {
                        keyStore.update(newKey)
                    }
                }
            }
        )
    }
    
    @StateObject private var keyStore = AuthenticationKeyEntryStore()
    @Environment(\.dismiss) private var dismiss
}

class AuthenticationKeyEntryStore: ObservableObject {
    
    // MARK: - Initialization
    
    init() {
        keys = storedKeys ?? []
        observeKeys()
    }
    
    // MARK: - Persistence
    
    private func observeKeys() {
        $keys
            .sink { [weak self] newKeys in
                self?.storedKeys = newKeys
            }
            .store(in: &observations)
    }
    
    private var observations = Set<AnyCancellable>()
    
    @Keychain("apiKeys") private var storedKeys: [AuthenticationKeyEntry]?
    
    // MARK: - (View-) Model
    
    func update(_ newKey: AuthenticationKeyEntry) {
        if let existingIndex = keys.firstIndex(where: { $0.id == newKey.id }) {
            keys[existingIndex] = newKey
        } else {
            keys.append(newKey)
        }
    }
    
    func delete(at offsets: IndexSet) {
        keys.remove(atOffsets: offsets)
    }
    
    @Published var keys: [AuthenticationKeyEntry] = []
}

struct AuthenticationKeyEntry: Codable, Identifiable {
    var providerIdentifier: ProviderIdentifier? {
        .init(rawValue: providerIdentifierValue)
    }
    
    init?(_ keyValue: String,
         providerIdentifierValue: String,
         name: String? = nil,
         description: String? = nil,
         id: UUID = UUID()) {
        if keyValue.isEmpty { return nil }
        self.id = id
        self.keyValue = keyValue
        self.providerIdentifierValue = providerIdentifierValue
        self.name = name
        self.description = description
    }
    
    let id: UUID // Unique identifier for each key entry
    let keyValue: String
    let providerIdentifierValue: String // Optional provider identifier
    let name: String? // Optional user-given name
    let description: String? // Optional user-provided description
}

enum ProviderIdentifier: String, CaseIterable, Identifiable {
    var displayName: String {
        switch self {
        case .anthropic: "Anthropic"
        case .openAI: "OpenAI"
        case .xAI: "xAI"
        }
    }
    
    var id: String { self.rawValue }
    
    case xAI
    case anthropic
    case openAI
}
