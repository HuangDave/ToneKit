import MetalKit.MTKView
import simd

open class TextureView: MTKView {
  private static let shaderSource =
  """
    #include <metal_stdlib>
    using namespace metal;

    typedef struct {
        float4 position           [[position]];
        float2 texture_coordinate [[user(texturecoord)]];
    } VertexInOut;

    vertex VertexInOut VertexShader(constant packed_float4 * position_in   [[buffer(0)]],
                                   constant packed_float2 * coordinate_in [[buffer(1)]],
                                   ushort                   vid           [[vertex_id]])
    {
        VertexInOut vertex_out;
        vertex_out.position           = position_in[vid];
        vertex_out.texture_coordinate = coordinate_in[vid];
        return vertex_out;
    }

    fragment float4 FragmentShader(VertexInOut      vertex_in  [[stage_in]],
                                         texture2d<float> input_texture [[texture(0)]])
    {
        constexpr sampler normalized_sampler(coord::normalized);
        return float4(input_texture.sample(normalized_sampler, vertex_in.texture_coordinate));
    }
  """

  open var vertexFunctionName: String { return "VertexShader" }
  open var fragmentFunctionName: String { return "FragmentShader" }

  private var quadVertices: [SIMD4<Float>] = [
    SIMD4<Float>(-1.0, -1.0, 0.0, 1.0),
    SIMD4<Float>( 1.0, -1.0, 0.0, 1.0),
    SIMD4<Float>(-1.0,  1.0, 0.0, 1.0),
    SIMD4<Float>( 1.0, -1.0, 0.0, 1.0),
    SIMD4<Float>(-1.0,  1.0, 0.0, 1.0),
    SIMD4<Float>( 1.0,  1.0, 0.0, 1.0),
  ]
  private var textureCoordinates: [SIMD2<Float>] = [
    SIMD2<Float>(0.0, 0.0),
    SIMD2<Float>(1.0, 0.0),
    SIMD2<Float>(0.0, 1.0),
    SIMD2<Float>(1.0, 0.0),
    SIMD2<Float>(0.0, 1.0),
    SIMD2<Float>(1.0, 1.0),
  ]
  private let metalDevice: MetalDevice
  internal(set) public var vertexFunction: MTLFunction!
  internal(set) public var fragmentFunction: MTLFunction!
  internal(set) public var renderPipeline: MTLRenderPipelineState!
  /// Semaphore to block rendering if all 3 drawables are in use and resume when next drawable is
  /// available again.
  public let renderSemaphore: DispatchSemaphore = DispatchSemaphore(value: 3)
  /// Current texture that is rendered on the view.
  internal(set) public var texture: MTLTexture?
  /// TRUE if the view should re-render the texture.
  public var isDirty: Bool = false

  // MARK: - Initializers

  required public init(coder: NSCoder) {
    fatalError("Not used")
  }

  public init(frame: CGRect, metalDevice: MetalDevice = MetalDevice.shared) {
    self.metalDevice = metalDevice
    super.init(frame: frame, device: metalDevice.device)
    device = MetalDevice.shared.device
    autoResizeDrawable = true
    framebufferOnly = true
    depthStencilPixelFormat = .invalid

    do {
      let library = try metalDevice.device.makeLibrary(source: TextureView.shaderSource,
                                                       options: nil)
      vertexFunction = metalDevice.makeFunction(name: vertexFunctionName, fromLibrary: library)
      fragmentFunction = metalDevice.makeFunction(name: fragmentFunctionName,
                                                  fromLibrary: library)
    } catch {
      fatalError("Failed to create vertex and fragment function.")
    }

    let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
    renderPipelineDescriptor.vertexFunction = vertexFunction
    renderPipelineDescriptor.fragmentFunction = fragmentFunction
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    do {
      renderPipeline = try metalDevice.device
        .makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    } catch {
      fatalError("Error occured when building render pipeline.")
    }
  }

  deinit {
    renderSemaphore.signal()
  }

  // MARK: - Rendering

  /// Render current texture with content mode: aspect fit. Each render pulls from a pool of 3
  /// available drawables.
  open func render() {
    guard let currentDrawableTexture = currentDrawable?.texture,
      let renderPassDescriptor = currentRenderPassDescriptor
      else {
        return
    }

    autoAdjustRenderFrame()
    renderSemaphore.wait()

    renderPassDescriptor.colorAttachments[0].texture = currentDrawableTexture
    renderPassDescriptor.colorAttachments[0].storeAction = .store
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)

    let commandBuffer = MetalDevice.shared.commandQueue.makeCommandBuffer()
    let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
    let quadVerticesLength = quadVertices.count * MemoryLayout<SIMD4<Float>>.size
    let textureCoordinatesLength = textureCoordinates.count * MemoryLayout<SIMD2<Float>>.size
    renderEncoder?.setRenderPipelineState(renderPipeline)
    renderEncoder?.setVertexBytes(&quadVertices, length: quadVerticesLength, index: 0)
    renderEncoder?.setVertexBytes(&textureCoordinates, length: textureCoordinatesLength, index: 1)
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

  open func willReceiveTextureUpdate() {}
  open func textureUpdateCancelled() {}
  open func process() {}
  /// Render the any newly processed texture received from a TextureOutput.
  ///
  /// - Parameters:
  ///   - texture: Texture to render.
  ///   - index: Not used
  open func update(texture: MTLTexture, at index: UInt = 0) {
    if self.texture !== texture || isDirty {
      self.texture = texture
      self.render()
    }
  }
}
