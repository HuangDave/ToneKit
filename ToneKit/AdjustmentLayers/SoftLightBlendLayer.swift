import Metal

open class SoftLightBlendLayer: ComputeLayer {
    open override var functionName: String { return "compute_soft_light_blend" }
    open override var inputCount: UInt { return 2 }

    public var opacity: Float {
        get { return uniforms.opacity!.value }
        set {
            uniforms.opacity!.value = newValue
            isDirty = true
        }
    }

    open override func registerUniforms() {
        uniforms.register(uniform: Uniform<Float>(initialValue: 1.0), withKey: "opacity")
    }
}
