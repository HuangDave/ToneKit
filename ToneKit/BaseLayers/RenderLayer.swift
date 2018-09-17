import Metal

public protocol RenderLayer: AnyObject {
    func setOutputSize(size: MTLSize)
    func renderTexture()
}

extension RenderLayer where Self: ComputeLayer {
    @available(*, unavailable, message:"Not available for Render Layers")
    public var inputTextures: [MTLTexture?]! {
        get { return nil }
        set { }
    }
}

extension RenderLayer where Self: ComputeLayer {
    public var inputCount: Int { return 0 }

    public func willReceiveTextureUpdate() { }

    public func setOutputSize(size: MTLSize) {
        outputSize = size
    }

    /// Renders a texture and outputs it to the configured TextureInput target.
    public func renderTexture() {
        if isDirty {
            isProcessing = true
            processTexture()
        }
        target?.update(texture: texture!, at: targetIndex)
    }
}