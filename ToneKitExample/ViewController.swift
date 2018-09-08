import UIKit
import ToneKit

class ViewController: UIViewController {
    @IBOutlet weak var textureView: TextureView!

    var texture: ImageTexture = ImageTexture(image:   UIImage(named: "sample_image_1")!,
                                             options: ImageTexture.defaultOptions)

    override func viewDidLoad() {
        super.viewDidLoad()
        //testPassThrough()
        testSolidColorLayer()
    }

    func testPassThrough() {
        let passthroughLayer = ComputeLayer()
        texture.setTarget(passthroughLayer)
        passthroughLayer.setTarget(textureView)
        texture.processTexture()
    }

    func testSolidColorLayer() {
        let solidColorLayer = SolidColorLayer()
        solidColorLayer.setOutputSize(size: MTLSize(width: 375, height: 375, depth: 1))
        solidColorLayer.color = UIColor.blue
        solidColorLayer.setTarget(textureView)
        solidColorLayer.renderTexture()
    }
}
