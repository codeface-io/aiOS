import SwiftUI
import Combine
import Foundation

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List(keyStore.keys) { key in
                Text(key.keyValue)
            }
            .navigationTitle("API Keys")
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
    
    @Published var keys: [AuthenticationKeyEntry] = []
}

struct AuthenticationKeyEntry: Codable, Identifiable {
    init(_ keyValue: String,
         providerIdentifierValue: String? = nil,
         name: String? = nil,
         description: String? = nil) {
        self.id = UUID()
        self.keyValue = keyValue
        self.providerIdentifierValue = providerIdentifierValue
        self.name = name
        self.description = description
    }
    
    let id: UUID // Unique identifier for each key entry
    let keyValue: String
    let providerIdentifierValue: String? // Optional provider identifier
    let name: String? // Optional user-given name
    let description: String? // Optional user-provided description
}
