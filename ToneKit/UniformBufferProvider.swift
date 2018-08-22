import simd
import Dispatch
import Metal.MTLBuffer

public protocol Buffer {
    var bufferCount: Int { get }
    var bufferSize:  Int { get }
    var semaphore:   DispatchSemaphore { get }
}

open class UniformBufferProvider {
    internal(set) public var buffers: [String: Buffer?] = [:]

    public final func waitForAllSemaphores() {
        buffers.forEach { (_, buffer) in
            buffer?.semaphore.wait()
        }
    }

    public final func signalAllSemaphores() {
        buffers.forEach { (_, buffer) in
            buffer?.semaphore.signal()
        }
    }
}

// MARK: - UniformBufferProvider Public Accessors
extension UniformBufferProvider {
    public subscript(identifier: String) -> Buffer {
        get { return buffers[identifier]!! as Buffer }
        set { buffers[identifier] = newValue }
    }
    public subscript(identifier: String) -> UniformBuffer<Float>? {
        return buffers[identifier] as? UniformBuffer<Float>
    }
    public subscript(identifier: String) -> UniformBuffer<Int>? {
        return buffers[identifier] as? UniformBuffer<Int>
    }
    public subscript(identifier: String) -> UniformBuffer<float4x4>? {
        return buffers[identifier] as? UniformBuffer<float4x4>
    }
    public subscript(identifier: String) -> UniformBuffer<float4>? {
        return buffers[identifier] as? UniformBuffer<float4>
    }
    public subscript(identifier: String) -> UniformBuffer<float3>? {
        return buffers[identifier] as? UniformBuffer<float3>
    }
    public subscript(identifier: String) -> UniformBuffer<float2>? {
        return buffers[identifier] as? UniformBuffer<float2>
    }
}

open class UniformBuffer<UniformType>: Buffer {
    public static var defaultBufferCount: Int { return 3 }
    public static var defaultBufferSize:  Int { return 1 }
    public let bufferCount: Int
    public let bufferSize: Int
    /// Array consiting of a pool of uniform MTLBuffers.
    internal(set) public var buffers: [MTLBuffer] = [MTLBuffer]()
    /// Index of the next available MTLBuffer to use.
    private(set) internal var nextAvailableBufferIndex: Int = 0
    internal(set) public var semaphore: DispatchSemaphore
    /// Init pool of uniform buffers with desired buffer count and desired size
    /// if uniform type is an array.
    ///
    /// - Parameters:
    ///     - count:        Number of uniform buffers to create.
    ///     - sizeOfBuffer: By default, the size should be 1 if not an array.
    public init(bufferCount count: Int = UniformBuffer.defaultBufferCount,
                sizeOfBuffer: Int = UniformBuffer.defaultBufferSize) {
        bufferCount = count
        semaphore   = DispatchSemaphore(value: self.bufferCount)
        bufferSize  = sizeOfBuffer * MemoryLayout<UniformType>.size
        // initialize and populate array of MTLBuffers...
        let device: MTLDevice = MetalDevice.shared.device
        for _ in 0..<self.bufferCount {
            buffers.append(device.makeBuffer(length: self.bufferSize,
                                             options: MTLResourceOptions())!)
        }
        semaphore.signal()
    }

    deinit {
        for _ in 0..<bufferCount {
            semaphore.signal()
        }
    }
    /// Gets the next available MTLBuffer and also copies the contents of the given
    /// pointer into the buffer.
    ///
    /// - Parameters:
    ///     -  pointer: Pointer of the contents to copy to the MTLBuffer.
    ///
    /// - Returns:      Next available uniform buffer with provided contents.
    public func nextAvailableBuffer(withContents pointer: UnsafeMutablePointer<UniformType>) -> MTLBuffer {
        let buffer = buffers[nextAvailableBufferIndex]
        nextAvailableBufferIndex = (nextAvailableBufferIndex + 1) % bufferCount
        memcpy(buffer.contents(), pointer, bufferSize)
        return buffer
    }
}
