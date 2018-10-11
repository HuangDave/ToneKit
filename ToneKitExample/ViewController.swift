import UIKit
import ToneKit

class ViewController: UIViewController {
    @IBOutlet weak var textureView: TextureView!

    var texture: ImageTexture = ImageTexture(image:   UIImage(named: "sample_image_1")!,
                                             options: ImageTexture.defaultOptions)

    override func viewDidLoad() {
        super.viewDidLoad()
        testLookupLayer()
    }

    func testPassThrough() {
        let passthroughLayer = ComputeLayer()
        texture.setTarget(passthroughLayer)
        passthroughLayer.setTarget(textureView)
        texture.processTexture()
    }

    // MARK: - Adjustment Layers

    func testBrightnessLayer() {
        let brightnessLayer = BrightnessLayer()
        brightnessLayer.brightness = -0.3
        texture.setTarget(brightnessLayer)
        brightnessLayer.setTarget(textureView)
        texture.processTexture()
    }

    func testLookupLayer() {
        let lookupLayer = LookupLayer(lookupImage: "sample_lookup.png")
        texture.setTarget(lookupLayer)
        lookupLayer.setTarget(textureView)
        texture.processTexture()
    }

    // MARK: - Render Layers

    func testSolidColorLayer() {
        let solidColorLayer = SolidColorLayer()
        solidColorLayer.setOutputSize(size: MTLSize(width: 375,
                                                    height: 375,
                                                    depth: 1))
        solidColorLayer.color = UIColor.blue
        solidColorLayer.setTarget(textureView)
        solidColorLayer.renderTexture()
    }
}
