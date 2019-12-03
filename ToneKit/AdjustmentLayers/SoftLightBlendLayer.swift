import Metal

open class SoftLightBlendLayer: ComputeLayer {
  open override var functionName: String { return "ComputeSoftLightBlend" }
  open override var inputCount: UInt { return 2 }

  open override func registerUniforms() {
    uniforms.register(uniform: Uniform<Float>(initialValue: 1.0), withKey: "intensity")
  }
}
