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
    ///     - index:   Index of the texture to update
    func update(texture: MTLTexture, at index: UInt)
}
