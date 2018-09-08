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

    @available(*, unavailable, message:"Should use renderTexture() to genereate output texture.")
    public func processTexture() { }
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
            // TODO: need to refactor this
            isProcessing = true
            computeSemaphore.wait()
            uniforms?.waitForAllSemaphores()
            generateOutputTextureIfNeeded()

            let commandBuffer = MetalDevice.shared.commandQueue.makeCommandBuffer()
            let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
            commandEncoder?.setComputePipelineState(computePipeline)
            commandEncoder?.setTexture(texture, index: 0)
            configureUniforms(for: commandEncoder)
            commandEncoder?.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupCount)
            commandEncoder?.endEncoding()
            commandBuffer?.commit()
            commandBuffer?.waitUntilCompleted()

            uniforms?.signalAllSemaphores()
            computeSemaphore.signal()
            isProcessing = false
            isDirty = false
            textureUpdateSemaphore.signal()
        }
        target?.update(texture: texture!, at: targetIndex)
    }
}
