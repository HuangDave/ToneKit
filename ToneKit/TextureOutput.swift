import Metal
import UIKit.UIImage
/// A TextureOutput object process a texture and outputs it to a TextureInput.
open class TextureOutput {
    public let textureUpdateSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    internal(set) public var texture: MTLTexture?
    /// Target to pass processed internal texture to when processing is complete.
    public var target: TextureInput?
    public var targetIndex: UInt = 0
    /// TRUE if the current texture is currently being processed.
    public var isProcessing: Bool = false
    /// TRUE if the current texture needs to be processed.
    public var isDirty: Bool = false

    deinit {
        textureUpdateSemaphore.signal()
    }

    open func notifyTargetForTextureUpdate() {
        target?.willReceiveTextureUpdate()
    }

    open func notifyTargetTextureUpdateCancelled() {
        target?.textureUpdateCancelled()
    }
    /// Sets the targat that the texture should be outputted to.
    ///
    /// - Parameters:
    ///     - target:   Target to output texture to.
    ///     - index:    Target index, defaults to 0.
    open func setTarget(_ target: TextureInput, atIndex index: UInt = 0) {
        self.target = target
        targetIndex = index
    }
    /// Should be overridden in inheriting class.
    open func processTexture() { }
    /// Creates a UIImage from current processed internal texture, if the texture is
    /// being processsed, the TextureOutput will wait for _textureUpdateSemaphore_ to
    /// be signaled before creating the UIImage.
    ///
    /// - Returns: The current processed texture as a UIImage.
    open func imageOutput() -> UIImage? {
        if isProcessing { textureUpdateSemaphore.wait() }
        guard let texture = self.texture else {
            fatalError("Requesting image output but texture is nil")
        }
        guard texture.width != 0 && texture.height != 0 else {
            fatalError("\(type(of: self)) - Error occurred while processing texture.")
        }
        return texture.uiImage()
    }
}
