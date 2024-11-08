import Foundation
import Security

@propertyWrapper
public struct Keychain<Value: Codable> {
    public init(_ key: String) {
        self.key = key
    }
    
    public var wrappedValue: Value? {
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
    public static func save<T: Encodable>(_ item: T, forKey key: String) {
        guard let itemData = try? JSONEncoder().encode(item) else {
            return
        }
        
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
    public static func load<T: Decodable>(forKey key: String) -> T? {
        // Set up the query for fetching data from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
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
