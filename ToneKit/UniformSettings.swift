import Metal.MTLBuffer
import simd

public protocol UniformBufferable {
  var bufferCount: Int { get }
  var bufferSize: Int { get }
  var nextAvailableBuffer: MTLBuffer { get }
}

// MARK: -
@dynamicMemberLookup
public final class UniformSettings {
  private var uniforms: [String: UniformBufferable?] = [:]
  /// Array containg the keys of the uniforms in the order that they were initially set.
  private var uniformOrder = [String]()
  public var uniformsList: [UniformBufferable] {
    return uniformOrder.map { uniforms[$0]!! }
  }

  public func register(uniform: UniformBufferable, withKey key: String) {
    guard uniformOrder.contains(key) == false else {
      fatalError("The following uniform has already been registered: \(key)")
    }
    uniforms[key] = uniform
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
