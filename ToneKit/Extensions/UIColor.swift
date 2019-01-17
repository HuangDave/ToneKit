import UIKit.UIColor

extension UIColor {
    /// Apple's Human Interface Guideline Colors
    /// - seealso:
    ///     https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/
    public enum Apple {
        static let red      = UIColor(red: 255, green: 59,  blue: 48)
        static let orange   = UIColor(red: 255, green: 149, blue: 0)
        static let yellow   = UIColor(red: 255, green: 204, blue: 0)
        static let green    = UIColor(red: 76,  green: 217, blue: 100)
        static let tealBlue = UIColor(red: 90,  green: 200, blue: 250)
        static let blue     = UIColor(red: 0,   green: 122, blue: 255)
        static let purple   = UIColor(red: 88,  green: 86,  blue: 214)
        static let pink     = UIColor(red: 255, green: 45,  blue: 85)
    }
    /// Initialize UIColor with hex value.
    ///
    /// - Parameters:
    ///     - hex: Hex value of color ranging from 0x000000 to 0xFFFFFF
    public convenience init(hex: UInt, alpha: CGFloat = 0.0) {
        let red   = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >>  8) & 0xFF) / 255.0
        let blue  = CGFloat((hex >>  0) & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    /// - Parameters:
    ///     - red:   Red componenet ranging from 0 to 255.
    ///     - green: Green componenet ranging from 0 to 255.
    ///     - blue:  Blue componenet ranging from 0 to 255.
    public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red:   CGFloat(red)   / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue:  CGFloat(blue)  / 255.0,
                  alpha: alpha)
    }
}
