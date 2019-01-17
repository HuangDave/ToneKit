import Metal

open class AlphaBlendLayer: ComputeLayer {
    public init() {
        super.init(functionName: "compute_alpha_blend", inputCount: 2)
        uniforms.opacity = UniformBuffer<Float>()
    }

    open override func encodeUniforms(for commandEncoder: MTLComputeCommandEncoder?) {
        guard let buffer = uniforms.opacity?
            .nextAvailableBuffer(withContents: &intensity) else {
                fatalError("Error getting MTLBuffer for intensity uniform")
        }
        commandEncoder?.setBuffer(buffer, offset: 0, index: 0)
    }
}
