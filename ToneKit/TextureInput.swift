import Metal
/// TextureInput is adopted by objects that receive a MTLTexture for rendering or processing.
public protocol TextureInput: AnyObject {
    // Array containing all input textures that are used by the TextureInput.
    var inputTextures: [MTLTexture?]! { get }
    var texture: MTLTexture? { get }
    /// True if _texture_ needs to be processed or rendered.
    var isDirty: Bool { get set }

    func willReceiveTextureUpdate()
    func textureUpdateCancelled()
    /// The TextureInput should handle the received texture when a new texture is received.
    ///
    /// - Parameters:
    ///     - texture: New texture.
    ///     - index:   Index of the texture to update
    func update(texture: MTLTexture, at index: UInt)
    func processTexture()
}
