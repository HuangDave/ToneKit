import Metal

extension MTLTextureUsage {
  public static var shaderReadWrite: MTLTextureUsage {
    return MTLTextureUsage(rawValue:
      (MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue))
  }
}
