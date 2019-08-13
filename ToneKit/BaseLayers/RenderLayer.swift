import Metal

public protocol RenderLayer: AnyObject {
    func setOutputSize(size: MTLSize)
    func render()
}

extension RenderLayer where Self: ComputeLayer {
    @available(*, unavailable, message:"Not available for Render Layers")
    public var inputTextures: [MTLTexture?]! {
        get { return nil }
        set { }
    }
}

extension RenderLayer where Self: ComputeLayer {
    public func willReceiveTextureUpdate() { }

    public func setOutputSize(size: MTLSize) {
        outputSize = size
    }

    /// Renders a texture and outputs it to the configured TextureInput target.
    public func render() {
        if isDirty {
            isProcessing = true
            process()
        }
        target?.update(texture: outputTexture!, at: targetIndex)
    }
}
