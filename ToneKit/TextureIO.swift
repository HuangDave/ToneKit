import Metal.MTLTexture
/// TextureInput is adopted by objects that receive a MTLTexture for rendering or processing.
public protocol TextureInput: AnyObject {
  var inputCount: UInt { get }
  var inputTextures: [MTLTexture?]! { get }
  var isDirty: Bool { get set }

  func willReceiveTextureUpdate()
  func textureUpdateCancelled()
  /// The TextureInput should handle the received texture when a new texture is received.
  ///
  /// - Parameters:
  ///     - texture: New texture.
  ///     - index: Index of the texture to update
  func update(texture: MTLTexture, at index: UInt)
}
/// TextureOutput is adopted by objects that processes texture(s) and output a final outputTexture.
public protocol TextureOutput: AnyObject {
  var target: TextureInput? { get set }
  var targetIndex: UInt { get set }
  var outputTexture: MTLTexture? { get }
  var outputSize: MTLSize { get }
  var isDirty: Bool { get set }

  func setTarget(_ target: TextureInput, at index: UInt)
  func process()
}

extension TextureOutput {
  public func setTarget(_ target: TextureInput, at index: UInt = 0) {
    self.target = target
    self.targetIndex = index
  }
}
/// TextureIO is adopted by objects that take in texture inputs and produce texture outputs.
public protocol TextureIO: TextureInput, TextureOutput {}
