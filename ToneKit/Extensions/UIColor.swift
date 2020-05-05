import UIKit.UIColor

extension UIColor {
  /// Initialize UIColor with hex value.
  ///
  /// - Parameters:
  ///   - hex: Hex value of color ranging from 0x000000 to 0xFFFFFF
  public convenience init(hex: UInt, alpha: CGFloat = 0.0) {
    let red = CGFloat((hex >> 16) & 0xFF) / 255.0
    let green = CGFloat((hex >>  8) & 0xFF) / 255.0
    let blue = CGFloat((hex >>  0) & 0xFF) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
  /// - Parameters:
  ///   - red:   Red componenet ranging from 0 to 255.
  ///   - green: Green componenet ranging from 0 to 255.
  ///   - blue:  Blue componenet ranging from 0 to 255.
  public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
    self.init(red: CGFloat(red)   / 255.0,
              green: CGFloat(green) / 255.0,
              blue: CGFloat(blue)  / 255.0,
              alpha: alpha)
  }
}
