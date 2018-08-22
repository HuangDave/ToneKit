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
    /// Called when a texture is updated, deal with incoming texture.
    ///
    /// - Parameters:
    ///     - texture: Texture to render or process.
    ///     - index:   Index of the texture to update
    func update(texture: MTLTexture, atIndex index: UInt)
    func processTexture()
}
