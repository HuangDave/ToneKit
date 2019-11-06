import MetalKit.MTKTextureLoader
import UIKit.UIImage
/// Image source used for image processing.
/// On initialization, the specified UIImage is loaded as a MTLTexture.
open class ImageTexture: TextureOutput {
    /// Default texture options for loading a iamge with MTLTextureLoader.
    @available(iOS 10.0, *)
    public static let defaultOptions: [MTKTextureLoader.Option: Any] = [
        .generateMipmaps: true,
        .allocateMipmaps: true,
        .SRGB:            false,
        .origin:          MTKTextureLoader.Origin.flippedVertically,
        .textureUsage:    MTLTextureUsage.shaderReadWrite.rawValue
    ]

    public var target: TextureInput?
    public var targetIndex: UInt = 0
    public internal(set) var outputTexture: MTLTexture?
    public var outputSize: MTLSize { return MTLSize(width: width, height: height, depth: 1) }
    public var width:  Int = 0
    public var height: Int = 0
    public var isDirty: Bool = false

    /// Loads a MTLTexture from an image using the MTKTextureLoader.
    /// This should be used for iOS 10.0+
    ///
    /// - Parameters:
    ///     - image:   Image to load.
    ///     - options: MTLTextureLoader options.
    public init(image: UIImage, options: [MTKTextureLoader.Option: Any] = ImageTexture.defaultOptions) {
        guard let data = ImageTexture.fixOrientation(forImage: image).pngData() else {
            fatalError("Unable to load PNG Representation of UIImage")
        }
        let textureLoader = MTKTextureLoader(device: MetalDevice.shared.device)
        do {
            outputTexture = try textureLoader.newTexture(data: data, options: options)
        } catch {
            fatalError("Unable to load texture from UIImage: \(error)")
        }
        width = outputTexture!.width
        height = outputTexture!.height
    }
    /// Notifies the texture's target to update/process the texture.
    open func process() {
        // notifyTargetForTextureUpdate()
        MetalDevice.shared.processingQueue.async {
            self.target?.update(texture: self.outputTexture!, at: self.targetIndex)
        }
    }
}

extension ImageTexture {
    /// Helper function to fix the image orientation of a UIImage since the orientation
    /// of the UIImage may sometimes be different from its CGImage counterpart.
    ///
    /// - Parameters:
    ///     - image: Image to fix.
    ///
    /// - Returns:   UIImage with adjusted orientation.
    public class func fixOrientation(forImage image: UIImage) -> UIImage {
        // no adjustments needed...
        guard image.imageOrientation != .up else { return image }
        // adjust orientation to Up....
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return fixedImage!
    }
}
