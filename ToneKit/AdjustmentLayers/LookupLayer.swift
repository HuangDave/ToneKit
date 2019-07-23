import MetalKit

open class LookupLayer: ComputeLayer {
    public static let defaultLookupTextureOptions: [MTKTextureLoader.Option : Any] = {
        var textureOptions = ImageTexture.defaultOptions
        textureOptions.removeValue(forKey: MTKTextureLoader.Option.origin)
        return textureOptions
    }()

    public var lookupTexture: ImageTexture? {
        didSet { isDirty = true }
    }

    public init() {
        super.init(functionName: "compute_lookup", inputCount: 2)
        uniforms.intensity = UniformBuffer<Float>()
        intensity = 1.0
    }

    public convenience init(lookupImage name: String) {
        self.init()
        lookupTexture = ImageTexture(image: UIImage(named: name)!,
                                     options: LookupLayer.defaultLookupTextureOptions)
    }

    override open func encodeTextures(for commandEncoder: MTLComputeCommandEncoder?) {
        guard lookupTexture != nil else {
            fatalError("Lookup texture is nil")
        }
        inputTextures[1] = lookupTexture?.texture
        super.encodeTextures(for: commandEncoder)
    }

    open override func encodeUniforms(for commandEncoder: MTLComputeCommandEncoder?) {
        guard let buffer = uniforms.intensity?
            .nextAvailableBuffer(withContents: &intensity) else {
                fatalError("Error getting MTLBuffer for intensity uniform")
        }
        commandEncoder?.setBuffer(buffer, offset: 0, index: 0)
    }
}
