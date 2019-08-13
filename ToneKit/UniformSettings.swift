import Metal.MTLBuffer
import os
import simd

public protocol UniformBufferable {
    var bufferCount: Int { get }
    var bufferSize:  Int { get }
    var nextAvailableBuffer: MTLBuffer { get }
}

@dynamicMemberLookup
public final class UniformSettings {
    private var uniforms: [String: UniformBufferable?] = [:]
    /// Array containg the keys of the uniforms in the order that they were initially set.
    private var uniformOrder = [String]()
    public var uniformsList: [UniformBufferable] {
        return uniformOrder.map {  uniforms[$0]!! }
    }

    public func register(uniform: UniformBufferable, withKey key: String) {
        uniforms[key] = uniform
        guard uniformOrder.contains(key) == false else {
            print("Warning - The following uniform has already been registered: \(key)")
            return
        }
        uniformOrder.append(key)
    }

    public func nextAvailableBuffer(key: String) -> MTLBuffer {
        guard let uniform = uniforms[key] else {
            fatalError("Uniform for \(key) was never set.")
        }
        return uniform!.nextAvailableBuffer
    }
}

// MARK: - UniformBufferProvider Public Accessors
extension UniformSettings {
    public subscript(dynamicMember member: String) -> Uniform<Float>? {
        return uniforms[member, default: nil] as? Uniform<Float>
    }
    public subscript(dynamicMember member: String) -> Uniform<Int>? {
        return uniforms[member, default: nil] as? Uniform<Int>
    }
    public subscript(dynamicMember member: String) -> Uniform<float4x4>? {
        return uniforms[member, default: nil] as? Uniform<float4x4>
    }
    public subscript(dynamicMember member: String) -> Uniform<SIMD4<Float>>? {
        return uniforms[member, default: nil] as? Uniform<SIMD4<Float>>
    }
    public subscript(dynamicMember member: String) -> Uniform<SIMD3<Float>>? {
        return uniforms[member, default: nil] as? Uniform<SIMD3<Float>>
    }
    public subscript(dynamicMember member: String) -> Uniform<SIMD2<Float>>? {
        return uniforms[member, default: nil] as? Uniform<SIMD2<Float>>
    }
    public subscript(dynamicMember member: String) -> Uniform<[SIMD4<Float>]>? {
        return uniforms[member, default: nil] as? Uniform<[SIMD4<Float>]>
    }
    public subscript(dynamicMember member: String) -> Uniform<[SIMD3<Float>]>? {
        return uniforms[member, default: nil] as? Uniform<[SIMD3<Float>]>
    }
    public subscript(dynamicMember member: String) -> Uniform<[SIMD2<Float>]>? {
        return uniforms[member, default: nil] as? Uniform<[SIMD2<Float>]>
    }
}

// MARK: -
public final class Uniform<Type>: UniformBufferable {
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
    ///     - count:        Number of uniform buffers to create.
    ///     - sizeOfBuffer: Memory size of the uniform type used for each buffer.
    ///     - initialValue
    public init(bufferCount count: Int = 3, sizeOfBuffer: Int = MemoryLayout<Type>.size, initialValue: Type) {
        bufferCount = count
        bufferSize = sizeOfBuffer
        buffers = [MTLBuffer](repeating: MetalDevice.shared.device.makeBuffer(length: bufferSize,
                                                                              options: MTLResourceOptions())!,
                              count: bufferCount)
        value = initialValue
    }
}
