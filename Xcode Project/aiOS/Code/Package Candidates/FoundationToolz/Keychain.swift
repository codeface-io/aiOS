import FoundationToolz
import Foundation
import Security
import SwiftyToolz

@propertyWrapper
public struct Keychain<Value: Codable> {
    public var wrappedValue: Value? {
        get {
            do {
                return try KeychainAccess.load(itemID)
            } catch {
                log(error: error.localizedDescription)
                return nil
            }
        }
        
        set {
            do {
                try KeychainAccess.save(newValue, at: itemID)
            } catch {
                log(error: error.localizedDescription)
            }
        }
    }
    
    public init(_ itemID: KeychainItemID) { self.itemID = itemID }
    
    private let itemID: KeychainItemID
}

public class KeychainAccess {
    public static func save(_ item: Encodable, at itemID: KeychainItemID) throws {
        let itemData = try item.encode()
        
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
    
    public static func load<Item: Decodable>(_ itemID: KeychainItemID) throws -> Item? {
        // Set up the query for fetching data from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemID.value,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Fetch the item from Keychain
        var itemReference: CFTypeRef?
        
        guard SecItemCopyMatching(query as CFDictionary, &itemReference) == noErr,
            let itemData = itemReference as? Data
        else {
            // an item for the given key simply does not exist in the keychain (yet)
            return nil
        }
           
        return try Item(jsonData: itemData)
    }
    
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
