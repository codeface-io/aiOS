import SwiftUI

@main
struct AIOSApp: App {
    var body: some Scene {
        WindowGroup {
            AIOSAppView()
        }
        
        #if os(macOS)
        Settings {
            APIKeySettingsView()
                .frame(minWidth: 300, minHeight: 200)
        }
        #endif
    }
}
