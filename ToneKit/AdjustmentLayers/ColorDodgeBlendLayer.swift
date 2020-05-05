import Metal

open class ColorDodgeBlendLayer: ComputeLayer {
  open override var functionName: String { return "ComputeColorDodgeBlend" }
  open override var inputCount: UInt { return 2 }

  open override func registerUniforms() {
    uniforms.register(uniform: Uniform<Float>(initialValue: 1.0), withKey: "intensity")
  }
}
