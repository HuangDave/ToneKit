import Metal

open class BrightnessLayer: ComputeLayer {
  open override var functionName: String { return "ComputeBrightness" }
  /// Brightness ranging from -0.3 to 0.3, with 0.0 being no change.
  public var intensity: Float {
    get { return uniforms.brightness!.value }
    set {
      uniforms.brightness!.value = newValue
      isDirty = true
    }
  }

  open override func registerUniforms() {
    uniforms.register(uniform: Uniform<Float>(initialValue: 0.0), withKey: "brightness")
  }
}
