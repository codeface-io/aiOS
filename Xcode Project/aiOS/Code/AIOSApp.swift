import SwiftUI

@main
struct aiOSApp: App {
    var body: some Scene {
        WindowGroup {
            AIOSAppView()
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
                .frame(minWidth: 300, minHeight: 200)
        }
        #endif
    }
}
