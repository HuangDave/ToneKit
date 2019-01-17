import Metal
/// The ComputeLayer performs a kernel compute operation on an input texture and outputs
/// the processed texture to its target for any further processing.
open class ComputeLayer: TextureOutput {
    /// The number of accepted texture inputs. The default count = 1 and should be overridden is
    /// different input count is desired.
    internal(set) public var inputCount: Int!
    /// Array containing all input textures that are used for processing.
    /// The size allocated for the array is based on the specified inputCount.
    internal(set) public var inputTextures: [MTLTexture?]!
    internal(set) public var computePipeline: MTLComputePipelineState!
    internal(set) public var computeSemaphore: DispatchSemaphore!
    internal(set) public var outputSize: MTLSize = MTLSize.zero
    /// Should be initialized if the layer requires any uniforms during processing.
    internal(set) public lazy var uniforms: UniformBufferProvider = UniformBufferProvider()
    /// Should be added to _uniforms_ and encoded into the MTLComputeCommandEncoder if needed.
    public var intensity: Float = 0.0 {
        didSet { isDirty = true }
    }
    /// Default threadgroup count of MTLSize(16, 16, 1)
    open var threadgroupCount: MTLSize {
        return MTLSize(width: 16, height: 16, depth: 1)
    }
    /// Calculate the threadgroup size for processing.
    ///
    /// The threadgroup size is obtained by dividing the output texture's size with the specified
    /// threadgroupCount size.
    ///
    /// ie. The default threadgroupCount is 8 x 8. If the texture size is 32 x 48,
    ///     then the threadgroupSize is 4 x 6.
    ///
    /// - Note: The quotient is rounded up to prevent a black/white border
    ///         when rendering the texture since compute functions on take integers position.
    open var threadgroups: MTLSize {
        return MTLSize(width:  Int(ceilf(Float(outputSize.width)  / Float(threadgroupCount.width))),
                       height: Int(ceilf(Float(outputSize.height) / Float(threadgroupCount.height))),
                       depth:  1)
    }

    // MARK: - Initializers

    /// Initializes a ComputeLayer with the specified kernel compute function.
    ///
    /// - Parameters:
    ///    - functionName: Name of the kernel compute function.
    public init(functionName: String = "compute_passthrough", inputCount: Int = 1) {
        super.init()
        let computeFunction = MetalDevice.shared.makeFunction(name: functionName)
        do {
            try computePipeline = MetalDevice.shared.device.makeComputePipelineState(function: computeFunction)
        } catch {
            fatalError("Error occurred when building compute pipeline for function: \(computeFunction)")
        }
        computeSemaphore = DispatchSemaphore(value: 3)
        self.inputCount = inputCount
        inputTextures = [MTLTexture?](repeating: nil, count: self.inputCount)
        isDirty = true
    }

    deinit {
        uniforms.signalAllSemaphores()
        computeSemaphore.signal()
    }

    // MARK: - Processing

    /// Creates an output texture for writing the output of the processed texture if necessary.
    open func generateOutputTextureIfNeeded() {
        if texture == nil ||
            texture?.width  != outputSize.width ||
            texture?.height != outputSize.height {
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                             width: outputSize.width,
                                                                             height: outputSize.height,
                                                                             mipmapped: false)
            textureDescriptor.usage = .shaderReadWrite
            texture = MetalDevice.shared.device.makeTexture(descriptor: textureDescriptor)
        }
    }
    /// Prepares the layer for processing.
    ///
    /// Should override to add more pre-processing tasks.
    ///
    /// - Returns: True if all checks pass or if all pre-processing tasks are completed,
    ///             otherwise return false and image processing is terminated.
    open func processingWillBegin() {
        if inputCount != 0 {
            guard inputTextures.first != nil else {
                textureUpdateCancelled()
                fatalError("Expecting an input but input texture is not set or is nil")
            }
        }
        computeSemaphore.wait()
        uniforms.waitForAllSemaphores()
        generateOutputTextureIfNeeded()
    }
    /// Encodes the desired MTLTextures on the command encoder.
    ///
    /// Should override for custom encoding.
    ///
    /// - Parameters:
    ///    - commandEncoder: The MTLComputeCommandEcoder used for processing.
    open func encodeTextures(for commandEncoder: MTLComputeCommandEncoder?) {
        if inputCount != 0 {
            // encode input textures if the layer requires input textures for processing...
            for i in 0..<inputCount {
                print("\(type(of: self)) setting texture as input: \(i)")
                commandEncoder?.setTexture(inputTextures[i], index: i)
            }
        }
        // if inputCount = 0, then the output texture will be encoded at index 0
        commandEncoder?.setTexture(texture, index: inputCount)
    }
    /// Encodes MTLBuffers containing desired uniforms on the command encoder.
    ///
    /// Should override for custom encoding.
    ///
    /// - Parameters:
    ///    - commandEncoder: The MTLComputeCommandEcoder used for processing.
    open func encodeUniforms(for commandEncoder: MTLComputeCommandEncoder?) {

    }

    open override func processTexture() {
        processingWillBegin()

        let commandBuffer = MetalDevice.shared.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(computePipeline)
        encodeTextures(for: commandEncoder)
        encodeUniforms(for: commandEncoder)
        commandEncoder?.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupCount)
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()

        processingDidFinish()
    }
    /// Called when processing is finished.
    /// Override to perform any other post-processing tasks.
    open func processingDidFinish() {
        uniforms.signalAllSemaphores()
        computeSemaphore.signal()
        isProcessing = false
        isDirty = false
        textureUpdateSemaphore.signal()
    }
}

// MARK: - TextureInput Implementation
extension ComputeLayer: TextureInput {
    public final func willReceiveTextureUpdate() {
        isProcessing = true
        notifyTargetForTextureUpdate()
    }

    public final func textureUpdateCancelled() {
        uniforms.signalAllSemaphores()
        computeSemaphore.signal()
        isProcessing = false
        notifyTargetTextureUpdateCancelled()
    }
    /// Called when adjustment layer receives a new texture. The layer will process the new layer if
    /// needed and send the new texture to its target.
    ///
    /// - Parameters:
    ///     - texture: New texture to process.
    ///     - index:   Index of texture to update if the layer
    ///                utilizes multiple inputs. By default index = 0.
    public func update(texture: MTLTexture, at index: UInt) {
        assert(index < inputCount, "Target input index should not be greater than the input count.")
        if inputTextures[Int(index)] !== texture || inputTextures[Int(index)] == nil || isDirty {
            inputTextures[Int(index)] = texture
            if index == 0 { // the output size should default to the size of the base input texture
                outputSize = MTLSizeMake(texture.width, texture.height, 1)
                processTexture()
            }
            target?.isDirty = true
        }
        target?.update(texture: self.texture!, at: targetIndex)
    }
}
