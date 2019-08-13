import MetalKit

open class LookupLayer: ComputeLayer {
    public static let defaultLookupTextureOptions: [MTKTextureLoader.Option : Any] = {
        var textureOptions = ImageTexture.defaultOptions
        textureOptions.removeValue(forKey: MTKTextureLoader.Option.origin)
        return textureOptions
    }()

    open override var functionName: String { return "compute_lookup" }
    open override var inputCount: UInt { return 2 }

    public var lookupTexture: ImageTexture? {
        didSet { isDirty = true }
    }

    public var intensity: Float {
        get { return uniforms.intensity!.value }
        set {
            uniforms.intensity!.value = newValue
            isDirty = true
        }
    }

    public convenience init(lookupImageNamed name: String) {
        self.init()
        lookupTexture = ImageTexture(image: UIImage(named: name)!,
                                     options: LookupLayer.defaultLookupTextureOptions)
    }

    // MARK: -

    open override func registerUniforms() {
        uniforms.register(uniform: Uniform<Float>(initialValue: 1.0), withKey: "intensity")
    }

    override open func encodeTextures(for commandEncoder: MTLComputeCommandEncoder?) {
        guard lookupTexture != nil else {
            fatalError("Lookup texture is nil")
        }
        inputTextures[1] = lookupTexture?.outputTexture
        super.encodeTextures(for: commandEncoder)
    }
}
