import MetalKit.MTKView
import simd

open class TextureView: MTKView {
    private var quadVertices: [SIMD4<Float>] = [
        SIMD4<Float>(-1.0, -1.0, 0.0, 1.0),
        SIMD4<Float>( 1.0, -1.0, 0.0, 1.0),
        SIMD4<Float>(-1.0,  1.0, 0.0, 1.0),
        SIMD4<Float>( 1.0, -1.0, 0.0, 1.0),
        SIMD4<Float>(-1.0,  1.0, 0.0, 1.0),
        SIMD4<Float>( 1.0,  1.0, 0.0, 1.0)
    ]
    private var textureCoordinates: [SIMD2<Float>] = [
        SIMD2<Float>(0.0, 0.0),
        SIMD2<Float>(1.0, 0.0),
        SIMD2<Float>(0.0, 1.0),
        SIMD2<Float>(1.0, 0.0),
        SIMD2<Float>(0.0, 1.0),
        SIMD2<Float>(1.0, 1.0)
    ]
    internal(set) public var vertexFunction: MTLFunction!
    internal(set) public var fragmentFunction: MTLFunction!
    internal(set) public var renderPipeline: MTLRenderPipelineState!
    /// Semaphore to block rendering if all 3 drawables are in use and resume
    /// when next drawable is available again.
    public let renderSemaphore: DispatchSemaphore = DispatchSemaphore(value: 3)
    /// Current texture that is rendered on the view.
    internal(set) public var texture: MTLTexture?
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
    }

    deinit {
        renderSemaphore.signal()
    }

    // MARK: - Rendering

    /// Render current texture with content mode: aspect fit.
    /// Each render pulls from a pool of 3 available drawables.
    open func render() {
        guard let currentDrawableTexture = currentDrawable?.texture,
              let renderPassDescriptor = currentRenderPassDescriptor
            else { return }

        autoAdjustRenderFrame()
        renderSemaphore.wait()

        renderPassDescriptor.colorAttachments[0].texture = currentDrawableTexture
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)

        let commandBuffer = MetalDevice.shared.commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(renderPipeline)
        renderEncoder?.setVertexBytes(&quadVertices,
                                      length: quadVertices.count * MemoryLayout<SIMD4<Float>>.size,
                                      index: 0)
        renderEncoder?.setVertexBytes(&textureCoordinates,
                                      length: textureCoordinates.count * MemoryLayout<SIMD2<Float>>.size,
                                      index: 1)
        renderEncoder?.setFragmentTexture(texture, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        renderEncoder?.endEncoding()
        commandBuffer?.addCompletedHandler({ _ -> Void in
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
    open var inputCount: UInt { return 1 }
    /// Array containing the current rendered texture if any.
    open var inputTextures: [MTLTexture?]! { return [texture] }

    open func willReceiveTextureUpdate() { }
    open func textureUpdateCancelled() { }
    open func process() { }
    /// Render the any newly processed texture received from a TextureOutput.
    ///
    /// - Parameters:
    ///     - texture:  Texture to render.
    ///     - index:    Not used
    open func update(texture: MTLTexture, at index: UInt = 0) {
        if self.texture !== texture || isDirty {
            self.texture = texture
            self.render()
        }
    }
}
