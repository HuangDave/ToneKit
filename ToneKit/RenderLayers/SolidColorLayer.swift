import Metal
import simd

open class SolidColorLayer: ComputeLayer, RenderLayer {
    /// Color to render.
    public var color: UIColor = .black

    public init(color: UIColor = .black) {
        super.init(functionName: "compute_solid_color", inputCount: 0)
        self.color = color
        uniforms.color = UniformBuffer<float4>(sizeOfBuffer: MemoryLayout<float4>.size)
    }

    open override func encodeUniforms(for commandEncoder: MTLComputeCommandEncoder?) {
        // get rgb components of UIColor and set into float4 a uniform for encoding...
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 0.0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        var colorUniform: float4 = float4([
            Float(red),
            Float(green),
            Float(blue),
            Float(alpha)
            ])
        colorUniform = float4(0,0,1,1)
        guard let buffer = uniforms.color?.nextAvailableBuffer(withContents: &colorUniform) else {
            fatalError("Error getting MTLBuffer for color uniform")
        }
        buffer.label = "SolidColorLayer - float4 color uniform"
        commandEncoder?.setBuffer(buffer, offset: 0, index: 0)
    }
}
