import Metal

open class BrightnessLayer: ComputeLayer {
    public init() {
        super.init(functionName: "compute_brightness")
        uniforms.brightness = UniformBuffer<Float>()
    }

    open override func encodeUniforms(for commandEncoder: MTLComputeCommandEncoder?) {
        guard let buffer = uniforms.brightness?
            .nextAvailableBuffer(withContents: &intensity) else {
                fatalError("Error getting MTLBuffer for brightness uniform")
        }
        commandEncoder?.setBuffer(buffer, offset: 0, index: 0)
    }
}
