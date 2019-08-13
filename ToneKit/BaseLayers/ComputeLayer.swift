import Metal

open class ComputeLayer: TextureIO {
    open var functionName: String { return "compute_passthrough" }
    open var inputCount: UInt { return 1 }
    /// Array containing all input textures that are used for processing.
    /// The size allocated for the array is based on the specified inputCount.
    public internal(set) var inputTextures: [MTLTexture?]!
    public internal(set) var computeFunction: MTLFunction!
    public internal(set) var computePipeline: MTLComputePipelineState!
    public internal(set) var computeSemaphore: DispatchSemaphore!
    public internal(set) var textureUpdateSemaphore = DispatchSemaphore(value: 1)
    /// Should be initialized if the layer requires any uniforms during processing.
    public internal(set) lazy var uniforms = UniformSettings()
    public var target: TextureInput?
    public var targetIndex: UInt = 0
    public internal(set) var outputTexture: MTLTexture?
    public internal(set) var outputSize: MTLSize = MTLSize.zero
    /// TRUE if the layer is currently being processed. This value is set to false when
    /// processingDidFinish() is completed.
    public internal(set) var isProcessing: Bool = false
    /// TRUE if the layer needs processing.
    public var isDirty: Bool = true
    /// If enabled = FALSE, then the layer will not be processed and the incoming texture will
    /// be passed directly to the target.
    public var enabled = true
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
    /// - Note: The quotient is rounded to prevent a black/white border when rendering the texture
    ///         since compute functions on take integers position.
    open var threadgroups: MTLSize {
        return MTLSize(width:  Int(ceilf(Float(outputSize.width)  / Float(threadgroupCount.width))),
                       height: Int(ceilf(Float(outputSize.height) / Float(threadgroupCount.height))),
                       depth:  1)
    }

    // MARK: - Initializers

    public init() {
        computeFunction = MetalDevice.shared.makeFunction(name: functionName)
        do {
            try computePipeline = MetalDevice.shared.device.makeComputePipelineState(function: computeFunction)
        } catch {
            fatalError("Error occurred when building compute pipeline for function: \(computeFunction.name)")
        }
        computeSemaphore = DispatchSemaphore(value: 3)
        inputTextures = [MTLTexture?](repeating: nil, count: Int(inputCount))
        registerUniforms()
    }

    deinit {
        computeSemaphore.signal()
    }

    // MARK: -

    /// Invoked during initialization to register any uniforms required during processing.
    ///
    /// Uniforms are automatically encoded to the MTLComputeCommandEncoder in the order they are registered.
    ///
    /// Should override to register any required uniforms.
    open func registerUniforms() {

    }
    /// Initializes an output texture for writing the output of the processed texture if necessary.
    open func generateOutputTextureIfNeeded() {
        if outputTexture == nil ||
            outputTexture?.width  != outputSize.width ||
            outputTexture?.height != outputSize.height {
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                             width: outputSize.width,
                                                                             height: outputSize.height,
                                                                             mipmapped: false)
            textureDescriptor.usage = .shaderReadWrite
            outputTexture = MetalDevice.shared.device.makeTexture(descriptor: textureDescriptor)
        }
    }
    /// Prepares the layer for processing.
    ///
    /// Should override to add more pre-processing tasks.
    ///
    /// - Returns: True if all checks pass or if all pre-processing tasks are completed,
    ///            otherwise return false and image processing is terminated.
    open func processingWillBegin() {
        if inputCount != 0 {
            guard inputTextures.first != nil else {
                textureUpdateCancelled()
                fatalError("Expecting an input but input texture is not set or is nil")
            }
        }
        computeSemaphore.wait()
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
            for i in 0 ..< Int(inputCount) {
                commandEncoder?.setTexture(inputTextures![i], index: i)
            }
        }
        // if inputCount = 0, then the output texture will be encoded at index 0
        commandEncoder?.setTexture(outputTexture, index: Int(inputCount))
    }
    /// Encodes MTLBuffers containing desired uniforms on the command encoder.
    ///
    /// Should override for custom encoding.
    ///
    /// - Parameters:
    ///    - commandEncoder: The MTLComputeCommandEcoder used for processing.
    open func encodeUniforms(for commandEncoder: MTLComputeCommandEncoder?) {
        let uniformsList = uniforms.uniformsList
        for bufferIndex in 0 ..< uniformsList.count {
            let buffer = uniformsList[bufferIndex].nextAvailableBuffer
            commandEncoder?.setBuffer(buffer, offset: 0, index: bufferIndex)
        }
    }

    open func process() {
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
        target?.willReceiveTextureUpdate()
    }

    public final func textureUpdateCancelled() {
        computeSemaphore.signal()
        isProcessing = false
        target?.textureUpdateCancelled()
    }
    /// Called when the layer receives a new texture. The layer will process the new texture if
    /// needed and send the new texture to its target.
    ///
    /// - Parameters:
    ///     - texture: New texture to process.
    ///     - index:   Index of texture to update if the layer
    ///                utilizes multiple inputs. By default index = 0.
    public func update(texture: MTLTexture, at index: UInt) {
        assert(index < inputCount, "Target input index should not be greater than the input count.")

        // skip the processing of the this layer if it is not enabled
        guard enabled else {
            if let inputTexture = inputTextures[0] {
                target?.update(texture: inputTexture, at: targetIndex)
            } else {
                target?.update(texture: texture, at: targetIndex)
            }
            return
        }

        if inputTextures[Int(index)] !== texture || inputTextures[Int(index)] == nil || isDirty {
            inputTextures[Int(index)] = texture
            if index == 0 {  // the output size should default to the size of the base input texture
                outputSize = MTLSizeMake(texture.width, texture.height, 1)
                process()
            }
            target?.isDirty = true
        }
        target?.update(texture: self.outputTexture!, at: targetIndex)
    }
}
