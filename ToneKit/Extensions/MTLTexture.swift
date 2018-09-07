import Metal.MTLTexture

public extension MTLTexture {
    /// - Returns: Returns the texture as a UIImage.
    public func uiImage() -> UIImage {
        let imageByteCount = width * height * 4
        let imageBytes = malloc(imageByteCount)
        let bytesPerRow = width * 4
        let region = MTLRegionMake2D(0, 0, width, height)

        getBytes(imageBytes!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)

        let provider = CGDataProvider(dataInfo: nil,
                                      data: imageBytes!,
                                      size: imageByteCount) { (data, _, _) in
                                        free(data)
            }!
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        let colorSpaceRef: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                        .byteOrder32Big]
        let renderingIntent = CGColorRenderingIntent.defaultIntent
        let imageRef = CGImage(width: width,
                               height: height,
                               bitsPerComponent: bitsPerComponent,
                               bitsPerPixel: bitsPerPixel,
                               bytesPerRow: bytesPerRow,
                               space: colorSpaceRef,
                               bitmapInfo: bitmapInfo,
                               provider: provider,
                               decode: nil,
                               shouldInterpolate: false,
                               intent: renderingIntent)
        return UIImage(cgImage: imageRef!, scale: 1.0, orientation: .downMirrored)
    }
}
