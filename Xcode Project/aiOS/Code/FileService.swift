import Foundation
import SwiftyToolz

enum FileService {
    static func contentsOfDocumentsFolder() throws -> [URL] {
        try fileManager.contentsOfDirectory(at: documentsFolder,
                                            includingPropertiesForKeys: nil)
    }
    
    static func contentsOfICloudDocumentsFolder() throws -> [URL] {
        guard let iCloudDocumentsFolder else {
            throw "iCloud Drive is not active on this device"
        }
        
        return try fileManager.contentsOfDirectory(at: iCloudDocumentsFolder,
                                                   includingPropertiesForKeys: nil)
    }
    
    static var isICloudDriveEnabledForApp: Bool {
        fileManager.ubiquityIdentityToken != nil
    }
    
    static var isICloudDriveEnabledOnDevice: Bool {
        fileManager.url(forUbiquityContainerIdentifier: nil) != nil
    }
    
    static var iCloudDocumentsFolder: URL? {
        fileManager
            .url(forUbiquityContainerIdentifier: nil)?
            .appending(component: "Documents")
    }
    
    static var documentsFolder: URL {
        get throws {
            guard let folderURL = fileManager.urls(for: .documentDirectory,
                                                   in: .userDomainMask).first else {
                throw "Found no Documents folder"
            }
            
            return folderURL
        }
    }
    
    private static let fileManager = FileManager.default
}
