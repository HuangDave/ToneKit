import Metal

extension MTLTextureUsage {
    static let shaderReadWrite = (MTLTextureUsage.shaderRead.rawValue |
                                  MTLTextureUsage.shaderWrite.rawValue)
}
