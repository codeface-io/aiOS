import SwiftUI
import Combine
import Foundation

#Preview("SettingsView") {
    SettingsView()
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(keyStore.keys) { key in
                    NavigationLink {
                        KeyDetailView(key: key, keyStore: keyStore)
                    } label: {
                        Text(key.displayTitle).font(.headline)
                    }
                }
                .onDelete(perform: keyStore.delete)
            }
            .navigationTitle("API Keys")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        let newKey = AuthenticationKeyEntry("", name: "New Key")
                        keyStore.keys.insert(newKey, at: 0)
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
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
    
    @StateObject private var keyStore = AuthenticationKeyEntryStore()
    @Environment(\.dismiss) private var dismiss
}

struct KeyDetailView: View {
    var body: some View {
        Form {
            Section {
                TextField("Key", text: $keyValue)
                TextField("Provider", text: $providerIdentifier)
                TextField("Name", text: $name)
                TextField("Description",
                          text: $description,
                          axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(name.isEmpty ? "API Key" : name)
        .onDisappear {
            // Save changes
            let updatedKey = AuthenticationKeyEntry(
                keyValue,
                providerIdentifierValue: providerIdentifier.isEmpty ? nil : providerIdentifier,
                name: name.isEmpty ? nil : name,
                description: description.isEmpty ? nil : description,
                id: originalKey.id
            )
            keyStore.update(updatedKey)
        }
    }
    
    // Initialization
    init(key: AuthenticationKeyEntry,
         keyStore: AuthenticationKeyEntryStore) {
        self.originalKey = key
        self.keyStore = keyStore
        _keyValue = State(initialValue: key.keyValue)
        _providerIdentifier = State(initialValue: key.providerIdentifierValue ?? "")
        _name = State(initialValue: key.name ?? "")
        _description = State(initialValue: key.description ?? "")
    }
    
    // State
    @State private var name: String
    @State private var keyValue: String
    @State private var providerIdentifier: String
    @State private var description: String

    // Basic Data
    let originalKey: AuthenticationKeyEntry
    @ObservedObject var keyStore: AuthenticationKeyEntryStore
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
    var displayTitle: String {
        name ?? String(keyValue.prefix(8))
    }
    
    init(_ keyValue: String,
         providerIdentifierValue: String? = nil,
         name: String? = nil,
         description: String? = nil,
         id: UUID = UUID()) {
        self.id = id
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
