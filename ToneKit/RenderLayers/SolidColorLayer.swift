import Metal
import simd
import UIKit

open class SolidColorLayer: ComputeLayer, RenderLayer {
  open override var functionName: String { return "ComputeSolidColor" }
  open override var inputCount: UInt { return 0 }

  public var color: UIColor = .black

  public init(color: UIColor = .black) {
    super.init()
    self.color = color
  }

  open override func registerUniforms() {
    uniforms.register(uniform: Uniform<SIMD4<Float>>(initialValue: SIMD4<Float>(repeating: 0.0)),
                      withKey: "color")
  }

  open override func encodeUniforms(for commandEncoder: MTLComputeCommandEncoder?) {
    // get rgb components of UIColor and set into float4 a uniform for encoding...
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    let colorValue = SIMD4<Float>([
      Float(red),
      Float(green),
      Float(blue),
      Float(alpha),
    ])
    uniforms.color!.value = colorValue

    super.encodeUniforms(for: commandEncoder)
  }
}
