import Metal

open class LightenBlendLayer: ComputeLayer, IntensityAdjustable {
    open override var functionName: String { return "compute_lighten_blend" }
    open override var inputCount: UInt { return 2 }

    open override func registerUniforms() {
        uniforms.register(uniform: Uniform<Float>(initialValue: 1.0), withKey: "intensity")
    }
}
