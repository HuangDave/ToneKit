import MetalKit.MTKView

open class TextureView: MTKView {
    private var quadVertices: [float4] = [
        float4(-1.0, -1.0, 0.0, 1.0),
        float4( 1.0, -1.0, 0.0, 1.0),
        float4(-1.0,  1.0, 0.0, 1.0),
        float4( 1.0, -1.0, 0.0, 1.0),
        float4(-1.0,  1.0, 0.0, 1.0),
        float4( 1.0,  1.0, 0.0, 1.0)
    ]
    private var textureCoordinates: [float2] = [
        float2(0.0, 0.0),
        float2(1.0, 0.0),
        float2(0.0, 1.0),
        float2(1.0, 0.0),
        float2(0.0, 1.0),
        float2(1.0, 1.0)
    ]
    internal(set) public var vertexFunction: MTLFunction!
    internal(set) public var fragmentFunction: MTLFunction!
    internal(set) public var renderPipeline: MTLRenderPipelineState!
    /// Semaphore to block rendering if all 3 drawables are in use and resume
    /// when next drawable is available again.
    public let renderSemaphore: DispatchSemaphore = DispatchSemaphore(value: 3)
    /// Current texture that is rendered on the view.
    internal(set) public var texture: MTLTexture?
    internal(set) public var uniforms: UniformBufferProvider = UniformBufferProvider()
    /// TRUE if the view should re-render the texture.
    public var isDirty: Bool = false

    // MARK: - Initializers

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public init(frame: CGRect) {
        super.init(frame: frame, device: MetalDevice.shared.device)
        commonInit()
    }

    internal func commonInit() {
        device                  = MetalDevice.shared.device
        autoResizeDrawable      = true
        framebufferOnly         = true
        depthStencilPixelFormat = .invalid
        vertexFunction = MetalDevice.shared.makeFunction(name: "vertex_main")
        fragmentFunction = MetalDevice.shared.makeFunction(name: "fragment_passthrough")

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            renderPipeline = try MetalDevice.shared.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            fatalError("Error occured when building render pipeline.")
        }
        let textureCoordinateBufferSize = quadVertices.count * MemoryLayout<float4>.size
        let vertexBufferSize            = textureCoordinates.count * MemoryLayout<float2>.size
        uniforms.textureCoordinates     = UniformBuffer<float4>(sizeOfBuffer: textureCoordinateBufferSize)
        uniforms.vertex                 = UniformBuffer<float2>(sizeOfBuffer: vertexBufferSize)
    }

    deinit {
        renderSemaphore.signal()
        uniforms.signalAllSemaphores()
    }

    // MARK: - Rendering

    /// Render current texture with content mode: aspect fit.
    /// Each render pulls from a pool of 3 available drawables.
    open func render() {
        guard let currentDrawableTexture = currentDrawable?.texture,
              let renderPassDescriptor = currentRenderPassDescriptor
            else { return }

        autoAdjustRenderFrame()

        guard let textureCoordinateBuffer = uniforms.textureCoordinates?
            .nextAvailableBuffer(withContents: &quadVertices) else {
                fatalError("Error getting MTLBuffer for textureCoordinates uniform")
        }
        guard let vertexBuffer = uniforms.vertex?
            .nextAvailableBuffer(withContents: &textureCoordinates) else {
                fatalError("Error getting MTLBuffer for vertex uniform")
        }

        renderSemaphore.wait()
        uniforms.waitForAllSemaphores()

        renderPassDescriptor.colorAttachments[0].texture = currentDrawableTexture
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)

        let commandBuffer = MetalDevice.shared.commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(renderPipeline)
        renderEncoder?.setVertexBuffer(textureCoordinateBuffer, offset: 0, index: 0)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 1)
        renderEncoder?.setFragmentTexture(texture, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        renderEncoder?.endEncoding()
        commandBuffer?.addCompletedHandler({ _ -> Void in
            self.uniforms.signalAllSemaphores()
            self.renderSemaphore.signal()
            self.draw()
        })
        commandBuffer?.present(currentDrawable!)
        commandBuffer?.commit()
    }

    /// Adjust _quadVertices_ for aspect fit.
    private func autoAdjustRenderFrame() {
        let size = drawableSize
        var ratio: CGFloat = size.width / CGFloat(texture!.width)
        if CGFloat(texture!.height) * ratio > size.height {
            ratio = size.height / CGFloat(texture!.height)
        }
        let resizedWidth = CGFloat(texture!.width) * ratio
        let resizedHeight = CGFloat(texture!.height) * ratio
        let normalizedX = Float(resizedWidth / size.width)
        let normalizedY = Float(resizedHeight / size.height)

        quadVertices[0].x = -normalizedX
        quadVertices[0].y = -normalizedY

        quadVertices[1].x =  normalizedX
        quadVertices[1].y = -normalizedY

        quadVertices[2].x = -normalizedX
        quadVertices[2].y =  normalizedY

        quadVertices[3].x =  normalizedX
        quadVertices[3].y = -normalizedY

        quadVertices[4].x = -normalizedX
        quadVertices[4].y =  normalizedY

        quadVertices[5].x =  normalizedX
        quadVertices[5].y =  normalizedY
    }
}

// MARK: - TextureInput Implementation
extension TextureView: TextureInput {
    /// Array containing the current rendered texture if any.
    open var inputTextures: [MTLTexture?]! { return [texture] }

    open func willReceiveTextureUpdate() { }
    open func textureUpdateCancelled() { }
    open func processTexture() { }
    /// Render the any newly processed texture received from a TextureOutput.
    ///
    /// - Parameters:
    ///     - texture:  Texture to render.
    ///     - index:    Not used
    open func update(texture: MTLTexture, at index: UInt = 0) {
        if self.texture !== texture || isDirty {
            self.texture = texture
            //autoreleasepool {
                self.render()
            //}
        }
    }
}
