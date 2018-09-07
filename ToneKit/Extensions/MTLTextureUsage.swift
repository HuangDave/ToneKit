import Metal

extension MTLTextureUsage {
    static let shaderReadWrite = MTLTextureUsage(rawValue: (MTLTextureUsage.shaderRead.rawValue |
                                                            MTLTextureUsage.shaderWrite.rawValue))
}
