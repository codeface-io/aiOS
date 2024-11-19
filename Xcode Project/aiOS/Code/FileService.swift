import Foundation
import SwiftyToolz

enum FileService {
    static func contentsOfDocumentsFolder() throws -> [URL] {
        try contents(ofFolder: documentsFolder)
    }
    
    static func contentsOfICloudDocumentsFolder() throws -> [URL] {
        guard let iCloudDocumentsFolder else {
            throw "iCloud Drive is not active on this device"
        }
        
        return try contents(ofFolder: iCloudDocumentsFolder)
    }
    
    static func contents(ofFolder folder: URL) throws -> [URL] {
        try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
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
