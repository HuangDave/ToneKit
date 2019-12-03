import Metal

public final class Uniform<Type>: UniformBufferable {
  private let metalDevice: MetalDevice
  /// Total number of allocated MTLBuffers.
  public let bufferCount: Int
  /// Total size of each buffer.
  public var bufferSize: Int
  public let buffers: [MTLBuffer]
  private var nextAvailableBufferIndex: Int = 0
  public var value: Type

  public var nextAvailableBuffer: MTLBuffer {
    let buffer = buffers[nextAvailableBufferIndex]
    nextAvailableBufferIndex = (nextAvailableBufferIndex + 1) % bufferCount
    buffer.contents().copyMemory(from: &value, byteCount: bufferSize)
    return buffer
  }

  // MARK: -

  /// Init pool of uniform buffers with desired buffer count if the uniform type is an array.
  ///
  /// - Parameters:
  ///   - metalDevice: Device containing the MTLDevice used to create the MTLBuffer.
  ///   - count: Number of uniform buffers to create.
  ///   - sizeOfBuffer: Memory size of the uniform type used for each buffer.
  ///   - initialValue: Initial value of the uniform.
  public init(metalDevice: MetalDevice = MetalDevice.shared,
              bufferCount count: Int = 3,
              sizeOfBuffer: Int = MemoryLayout<Type>.size,
              initialValue: Type) {
    self.metalDevice = metalDevice
    bufferCount = count
    bufferSize = sizeOfBuffer
    buffers = [MTLBuffer](
      repeating: metalDevice.device.makeBuffer(length: bufferSize, options: MTLResourceOptions())!,
      count: bufferCount)
    value = initialValue
  }
}
