import Dispatch
import Metal.MTLBuffer
import simd

public protocol Buffer {
    var bufferCount: Int { get }
    var bufferSize:  Int { get }
    var semaphore:   DispatchSemaphore { get }
}

@dynamicMemberLookup
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
    public subscript <UniformType: Buffer> (dynamicMember member: String) -> UniformType? {
        get { return buffers[member, default: nil] as? UniformType }
        set { buffers[member] = newValue                           }
    }
    public subscript(dynamicMember member: String) -> UniformBuffer<Float>? {
        return buffers[member, default: nil] as? UniformBuffer<Float>
    }
    public subscript(dynamicMember member: String) -> UniformBuffer<Int>? {
        return buffers[member, default: nil] as? UniformBuffer<Int>
    }
    public subscript(dynamicMember member: String) -> UniformBuffer<float4x4>? {
        return buffers[member, default: nil] as? UniformBuffer<float4x4>
    }
    public subscript(dynamicMember member: String) -> UniformBuffer<float4>? {
        return buffers[member, default: nil] as? UniformBuffer<float4>
    }
    public subscript(dynamicMember member: String) -> UniformBuffer<float3>? {
        return buffers[member, default: nil] as? UniformBuffer<float3>
    }
    public subscript(dynamicMember member: String) -> UniformBuffer<float2>? {
        return buffers[member, default: nil] as? UniformBuffer<float2>
    }
}

open class UniformBuffer<UniformType>: Buffer {
    public static var defaultBufferCount: Int { return 3 }
    public static var defaultBufferSize:  Int { return 1 }
    /// Total number of allocated buffers.
    public let bufferCount: Int
    /// Total size of each buffer.
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
