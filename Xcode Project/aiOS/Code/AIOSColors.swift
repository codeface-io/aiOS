import SwiftyToolz

extension DynamicColor {
    static var aiOSLevel0: DynamicColor {
        .in(light: .gray(brightness: 0.85),
            darkness: .gray(brightness: 0.0))
    }
    
    static var aiOSLevel1: DynamicColor {
        .in(light: .gray(brightness: 0.9),
            darkness: .gray(brightness: 0.05))
    }
    
    static var aiOSLevel2: DynamicColor {
        .in(light: .gray(brightness: 0.95),
            darkness: .gray(brightness: 0.1))
    }
    
    static var aiOSLevel3: DynamicColor {
        .in(light: .gray(brightness: 1.0),
            darkness: .gray(brightness: 0.15))
    }
}
