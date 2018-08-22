import Metal

public extension MTLSize {
    static var zero: MTLSize { return MTLSize(width: 0, height: 0, depth: 0) }
}

public func == (lhs: MTLSize, rhs: MTLSize) -> Bool {
    return (lhs.width  == rhs.width) &&
           (lhs.height == rhs.height) &&
           (lhs.depth  == rhs.depth)
}
