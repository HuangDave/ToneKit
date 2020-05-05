import Foundation
import ToneKit

enum ExampleCategory: Int, CaseIterable {
  case adjustments
  case blendModes

  enum Adjustments: Int, CaseIterable {
    case brightness
    case lookup
    case passThrough
    case whiteBalance

    var name: String {
      switch self {
      case .brightness:   return "Brightness"
      case .lookup:       return "Lookup"
      case .passThrough:  return "Pass Through"
      case .whiteBalance: return "White Balance"
      }
    }
  }

  enum BlendModes: Int, CaseIterable {
    case alpha
    case colorDodge
    case darken
    case hardLight
    case lighten
    case linearDodge
    case multiply
    case overlay
    case screen
    case softLight

    var name: String {
      switch self {
      case .alpha:       return "Alpha"
      case .colorDodge:  return "Color Dodge"
      case .darken:      return "Darken"
      case .hardLight:   return "Hard Light"
      case .lighten:     return "Lighten"
      case .linearDodge: return "Linear Dodge"
      case .multiply:    return "Multiply"
      case .overlay:     return "Overlay"
      case .screen:      return "Screen"
      case .softLight:   return "Soft Light"
      }
    }

    var computeLayer: ComputeLayer {
      switch self {
      case .alpha:       return AlphaBlendLayer()
      case .colorDodge:  return ColorDodgeBlendLayer()
      case .darken:      return DarkenBlendLayer()
      case .hardLight:   return HardLightBlendLayer()
      case .lighten:     return LightenBlendLayer()
      case .linearDodge: return LinearDodgeBlendLayer()
      case .multiply:    return MultiplyBlendLayer()
      case .overlay:     return OverlayBlendLayer()
      case .screen:      return ScreenBlendLayer()
      case .softLight:   return SoftLightBlendLayer()
      }
    }
  }
}
