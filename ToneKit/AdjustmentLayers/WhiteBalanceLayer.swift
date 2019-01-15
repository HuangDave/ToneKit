import Metal

open class WhiteBalanceLayer: ComputeLayer {
    /// Ranges between -0.4 and 1.2
    public var temperature: Float = 0.0 {
        didSet { isDirty = true }
    }
    /// Ranges from 0.0 to 1.0, with 0.0 being no effect.
    public var tint: Float = 0.0 {
        didSet { isDirty = true }
    }

    public init() {
        super.init(functionName: "compute_white_balance")
        uniforms.temperature = UniformBuffer<Float>()
        uniforms.tint = UniformBuffer<Float>()
    }

    open override func encodeUniforms(for commandEncoder: MTLComputeCommandEncoder?) {
        guard let temperatureBuffer = uniforms.temperature?
            .nextAvailableBuffer(withContents: &temperature) else {
                fatalError("Error getting MTLBuffer for temperature uniform")
        }
        guard let tintBuffer = uniforms.tint?
            .nextAvailableBuffer(withContents: &tint) else {
                fatalError("Error getting MTLBuffer for tint uniform")
        }
        commandEncoder?.setBuffer(temperatureBuffer, offset: 0, index: 0)
        commandEncoder?.setBuffer(tintBuffer, offset: 0, index: 1)
    }
}
