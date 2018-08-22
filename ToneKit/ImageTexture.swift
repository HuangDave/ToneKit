import UIKit.UIImage
import MetalKit.MTKTextureLoader
/// Image source used for image processing.
/// On initialization, the specified UIImage is loaded as a MTLTexture.
open class ImageTexture: TextureOutput {
    /// Default texture options for loading a iamge with MTLTextureLoader.
    @available(iOS 10.0, *)
    public static let defaultOptions: [MTKTextureLoader.Option: Any] = [
        MTKTextureLoader.Option.generateMipmaps: true,
        MTKTextureLoader.Option.allocateMipmaps: true,
        MTKTextureLoader.Option.SRGB:            false,
        MTKTextureLoader.Option.origin:          MTKTextureLoader.Origin.flippedVertically,
        MTKTextureLoader.Option.textureUsage:    MTLTextureUsage.shaderReadWrite
    ] as [MTKTextureLoader.Option: Any]

    public var width:  Int = 0
    public var height: Int = 0
    /// Loads the image as a MTLTexture with RGBA8Unorm pixel format in RGB color space.
    /// The UIImage's image orientation is adjusted if the orientation is not facing up.
    ///
    /// - Parameters:
    ///     - image: Image to load.
    @available(iOS, deprecated: 10.0, message: "Use init(image:, options: )")
    public init(image: UIImage) {
        super.init()
        guard let cgImage = ImageTexture.fixOrientation(forImage: image).cgImage else {
            fatalError("Unable to retreive CGImage from image.!")
        }

        width  = cgImage.width
        height = cgImage.height

        let rawData = calloc(width * height * 4, MemoryLayout<UInt8>.size)
        defer { free(rawData) }

        // setup bitmap context for getting the image as a texture
        let colorSpaceRef    = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel    = 4
        let bytesPerRow      = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                        CGBitmapInfo.byteOrder32Big]
        let bitmapContext = CGContext(data: rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpaceRef,
                                      bitmapInfo: bitmapInfo.rawValue)
        // flip the axis vertically
        bitmapContext!.translateBy(x: 0, y: CGFloat(height))
        bitmapContext!.scaleBy(x: 1, y: -1)
        bitmapContext!.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        // draw bitmap onto texture
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                         width: width,
                                                                         height: height,
                                                                         mipmapped: false)
        texture = MetalDevice.shared.device.makeTexture(descriptor: textureDescriptor)
        texture!.replace(region: MTLRegionMake2D(0, 0, width, height),
                         mipmapLevel: 0,
                         withBytes: rawData!,
                         bytesPerRow: bytesPerRow)
    }
    /// Loads a MTLTexture from an image using the MTKTextureLoader.
    /// This should be used for iOS 10.0+
    ///
    /// - Parameters:
    ///     - image:   Image to load.
    ///     - options: Options for loading texture.
    @available(iOS 10.0, *)
    public init(image: UIImage, options: [MTKTextureLoader.Option: Any] = ImageTexture.defaultOptions) {
        super.init()
        guard let data = ImageTexture.fixOrientation(forImage: image).pngData() else {
            fatalError("Unable to load PNG Representation of UIImage")
        }
        let textureLoader = MTKTextureLoader(device: MetalDevice.shared.device)
        do {
            texture = try textureLoader.newTexture(data: data, options: options)
        } catch {
            fatalError("Unable to load texture from UIImage: \(error)")
        }
        width = texture!.width
        height = texture!.height
    }
    /// Notify targets to begin processing the texture.
    open override func processTexture() {
        notifyTargetForTextureUpdate()
        MetalDevice.shared.processingQueue.async {
            self.target?.update(texture: self.texture!, atIndex: self.targetIndex)
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
    /// - Returns:   Returns UIImage with adjusted orientation.
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
