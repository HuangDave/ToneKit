import Metal

open class BrightnessLayer: ComputeLayer {

    public var brightness: Float = 0.0

    public init() {
        super.init(functionName: "compute_brightness")
        uniforms.brightness = UniformBuffer<Float>()
    }

    open override func configureUniforms(for commandEncoder: MTLComputeCommandEncoder?) {
        guard let buffer = uniforms.brightness?
            .nextAvailableBuffer(withContents: &brightness) else {
                fatalError("Error getting MTLBuffer for brightness uniform")
        }
        commandEncoder?.setBuffer(buffer, offset: 0, index: 0)
    }
}
