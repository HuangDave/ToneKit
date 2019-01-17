import Metal

open class DarkenBlendLayer: ComputeLayer {
    public init() {
        super.init(functionName: "compute_darken_blend", inputCount: 2)
        uniforms.intensity = UniformBuffer<Float>()
    }

    open override func encodeUniforms(for commandEncoder: MTLComputeCommandEncoder?) {
        guard let buffer = uniforms.intensity?
            .nextAvailableBuffer(withContents: &intensity) else {
                fatalError("Error getting MTLBuffer for intensity uniform")
        }
        commandEncoder?.setBuffer(buffer, offset: 0, index: 0)
    }
}
