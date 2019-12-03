import Metal

open class WhiteBalanceLayer: ComputeLayer {
  open override var functionName: String { return "ComputeWhiteBalance" }
  /// Ranges between -0.4 and 1.2
  public var temperature: Float {
    get { return uniforms.temperature!.value }
    set {
      uniforms.temperature!.value = newValue
      isDirty = true
    }
  }
  /// Ranges from 0.0 to 1.0, with 0.0 being no effect.
  public var tint: Float {
    get { return uniforms.tint!.value }
    set {
      uniforms.tint!.value = newValue
      isDirty = true
    }
  }

  open override func registerUniforms() {
    uniforms.register(uniform: Uniform<Float>(initialValue: 0.0), withKey: "temperature")
    uniforms.register(uniform: Uniform<Float>(initialValue: 0.0), withKey: "tint")
  }
}
