import simd

public extension float4 {
    public init(_ xyz: float3, _ w: Float) {
        self = float4(xyz.x, xyz.y, xyz.z, w)
    }
}

public func == (lhs: float3, rhs: float3) -> Bool {
    return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
}

public func == (lhs: float4x4, rhs: float4x4) -> Bool {
    for i in 0..<4 {
        return lhs[i] == rhs[i]
    }
    return true
}
