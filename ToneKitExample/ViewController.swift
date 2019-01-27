import UIKit
import ToneKit

class ViewController: UIViewController {
    @IBOutlet weak var textureView: TextureView!

    var texture: ImageTexture = ImageTexture(image:   UIImage(named: "sample_image_1")!,
                                             options: ImageTexture.defaultOptions)
    var computeLayer: ComputeLayer? {
        didSet {
            if computeLayer != nil {
                computeLayer!.setTarget(textureView)
                texture.processTexture()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        testWhiteBalance()
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
        brightnessLayer.intensity  = -0.3
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

    func testWhiteBalance() {
        let whiteBalanceLayer = WhiteBalanceLayer()
        texture.setTarget(whiteBalanceLayer)
        whiteBalanceLayer.temperature = 1.2
        whiteBalanceLayer.tint = 0.5
        computeLayer = whiteBalanceLayer
    }

    // MARK: - Render Layers

    func testSolidColorLayer() {
        let solidColorLayer = SolidColorLayer()
        solidColorLayer.setOutputSize(size: MTLSize(width: 375, height: 375, depth: 1))
        solidColorLayer.color = UIColor.blue
        solidColorLayer.setTarget(textureView)
        solidColorLayer.renderTexture()
    }
}
