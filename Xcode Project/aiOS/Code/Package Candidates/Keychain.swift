import Foundation
import Security

@propertyWrapper
public struct Keychain<Value: Codable> {
    public init(_ item: KeychainItemID) { self.itemID = item }
    
    public var wrappedValue: Value? {
        get { KeychainAccess.load(itemID) }
        set { KeychainAccess.save(newValue, at: itemID) }
    }
    
    private let itemID: KeychainItemID
}

public class KeychainAccess {
    /// Saves a string to Keychain for a given key
    /// - Parameters:
    ///   - key: The key to associate with the data
    ///   - data: The string data to be stored
    public static func save<T: Encodable>(_ item: T, at itemID: KeychainItemID) {
        guard let itemData = try? JSONEncoder().encode(item) else {
            return
        }
        
        // Create a query dictionary for Keychain operations
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemID.value,
            kSecValueData as String: itemData,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
        ]
        
        // Delete any existing item for this key to avoid duplicates
        SecItemDelete(query as CFDictionary)
        
        // Add the new keychain item with the data
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Loads a string from Keychain for a given key
    /// - Parameter key: The key associated with the data to retrieve
    /// - Returns: The string if found, otherwise nil
    public static func load<T: Decodable>(_ itemID: KeychainItemID) -> T? {
        // Set up the query for fetching data from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemID.value,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Fetch the item from Keychain
        var item: CFTypeRef?
        
        guard SecItemCopyMatching(query as CFDictionary, &item) == noErr,
            let itemData = item as? Data
        else {
            return nil
        }
                
        return try? JSONDecoder().decode(T.self, from: itemData)
    }
    
    /// Deletes a string from Keychain for a given key
    /// - Parameter key: The key associated with the data to delete
    public static func delete(_ itemID: KeychainItemID) {
        // Set up the query to identify which item to delete
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemID.value
        ]
        
        // Delete the item from Keychain
        SecItemDelete(query as CFDictionary)
    }
}

public struct KeychainItemID {
    public init(_ value: String) {
        self.value = value
    }
    
    let value: String
}
