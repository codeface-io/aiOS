import Foundation
import Security

@propertyWrapper
public struct Keychain {
    public init(key: String) {
        self.key = key
    }
    
    public var wrappedValue: String? {
        get {
            KeychainAccess.load(forKey: key)
        }
        set {
            if let newValue {
                KeychainAccess.save(newValue, forKey: key)
            } else {
                KeychainAccess.delete(forKey: key)
            }
        }
    }
    
    private let key: String
}

public class KeychainAccess {
    /// Saves a string to Keychain for a given key
    /// - Parameters:
    ///   - key: The key to associate with the data
    ///   - data: The string data to be stored
    public static func save(_ item: String, forKey key: String) {
        // Convert the string data into a Data object which Keychain can store
        guard let itemData = item.data(using: .utf8) else { return }
        
        // Create a query dictionary for Keychain operations
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
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
    public static func load(forKey key: String) -> String? {
        // Set up the query for fetching data from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Fetch the item from Keychain and convert it back to String
        var item: CFTypeRef?
        
        guard SecItemCopyMatching(query as CFDictionary, &item) == noErr,
              let existingItem = item as? Data,
              let itemString = String(data: existingItem, encoding: .utf8)
        else {
            return nil
        }
                
        return itemString
    }
    
    /// Deletes a string from Keychain for a given key
    /// - Parameter key: The key associated with the data to delete
    public static func delete(forKey key: String) {
        // Set up the query to identify which item to delete
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        // Delete the item from Keychain
        SecItemDelete(query as CFDictionary)
    }
}
