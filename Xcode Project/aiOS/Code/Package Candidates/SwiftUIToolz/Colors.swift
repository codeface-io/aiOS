import SwiftUI
import SwiftyToolz

// TODO: all these color extensions are from SwiftUIOToolzOLD and should be integrated back there

public extension SwiftUI.Color {
    
    static var random: SwiftUI.Color {
        SwiftUI.Color(SwiftyToolz.Color.random)
    }
    
    init(_ color: SwiftyToolz.Color) {
        self.init(red: color.red,
                  green: color.green,
                  blue: color.blue,
                  opacity: color.alpha)
    }
}

public extension SwiftUI.Color {
    #if os(macOS)
    
    static func dynamic(_ dynamicColor: DynamicColor) -> SwiftUI.Color {
        .init(NSColor(dynamicColor))
    }
    
    init(_ uiColor: UXColor) {
        switch uiColor {
        case .rgba(let color):
            self.init(color)
        case .system(let systemColor):
            self.init(systemColor)
        case .dynamic(let dynamicColor):
            self.init(dynamicColor)
        }
    }
    
    init(_ systemColor: SystemColor) {
        switch systemColor {
        case .text: self.init(NSColor.textColor)
        case .label: self.init(NSColor.labelColor)
        case .red: self.init(NSColor.systemRed)
        case .orange: self.init(NSColor.systemOrange)
        case .yellow: self.init(NSColor.systemYellow)
        case .green: self.init(NSColor.systemGreen)
        case .blue: self.init(NSColor.systemBlue)
        case .purple: self.init(NSColor.systemPurple)
        case .gray: self.init(NSColor.systemGray)
        case .secondaryLabel: self.init(NSColor.secondaryLabelColor)
        case .teal: self.init(NSColor.systemTeal)
        case .accent: self = .accentColor
        }
    }
    
    init(_ dynamicColor: DynamicColor) {
        self = .dynamic(lightMode: dynamicColor.lightMode,
                        darkMode: dynamicColor.darkMode)
    }
    
    static func dynamic(lightMode: SwiftyToolz.Color,
                        darkMode: SwiftyToolz.Color) -> SwiftUI.Color {
        .init(NSColor(lightMode: lightMode,
                      darkMode: darkMode))
    }
    
    #else
    
    static func dynamic(lightMode: SwiftyToolz.Color,
                        darkMode: SwiftyToolz.Color) -> SwiftUI.Color {
        .init(UIColor(lightMode: lightMode,
                      darkMode: darkMode))
    }
    
    static func dynamic(_ dynamicColor: DynamicColor) -> SwiftUI.Color {
        .init(UIColor(dynamicColor))
    }
    
    #endif
}

#if os(macOS)

public extension NSColor {
    
    convenience init(_ dynamicColor: SwiftyToolz.DynamicColor) {
        self.init(lightMode: dynamicColor.lightMode,
                  darkMode: dynamicColor.darkMode)
    }
    
    convenience init(lightMode: SwiftyToolz.Color,
                     darkMode: SwiftyToolz.Color) {
        self.init(lightMode: NSColor(lightMode),
                  darkMode: NSColor(darkMode))
    }
    
    convenience init(lightMode: NSColor,
                     darkMode: NSColor) {
        self.init(name: nil) { appearance in
            switch appearance.name {
            case .aqua,
                .vibrantLight,
                .accessibilityHighContrastAqua,
                .accessibilityHighContrastVibrantLight:
                return lightMode
            case .darkAqua,
                .vibrantDark,
                .accessibilityHighContrastDarkAqua,
                .accessibilityHighContrastVibrantDark:
                return darkMode
            default:
                return lightMode
            }
        }
    }
    
    convenience init(_ swiftyToolzColor: SwiftyToolz.Color) {
        self.init(red: swiftyToolzColor.red,
                  green: swiftyToolzColor.green,
                  blue: swiftyToolzColor.blue,
                  alpha: swiftyToolzColor.alpha)
    }
}

#else

public extension UIColor {
    
    convenience init(_ dynamicColor: SwiftyToolz.DynamicColor) {
        self.init(lightMode: dynamicColor.lightMode,
                  darkMode: dynamicColor.darkMode)
    }
    
    convenience init(lightMode: SwiftyToolz.Color,
                     darkMode: SwiftyToolz.Color) {
        self.init(lightMode: UIColor(lightMode),
                  darkMode: UIColor(darkMode))
    }
    
    convenience init(lightMode: UIColor,
                     darkMode: UIColor) {
        self.init { traits -> UIColor in
            if traits.userInterfaceStyle == .dark {
                darkMode
            } else {
                lightMode
            }
        }
    }
    
    convenience init(_ swiftyToolzColor: SwiftyToolz.Color) {
        self.init(red: swiftyToolzColor.red,
                  green: swiftyToolzColor.green,
                  blue: swiftyToolzColor.blue,
                  alpha: swiftyToolzColor.alpha)
    }
}

#endif
