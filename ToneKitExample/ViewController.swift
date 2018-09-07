import UIKit
import ToneKit

class ViewController: UIViewController {
    @IBOutlet weak var textureView: TextureView!

    var texture: ImageTexture = ImageTexture(image:   UIImage(named: "sample_image_1")!,
                                             options: ImageTexture.defaultOptions)

    override func viewDidLoad() {
        super.viewDidLoad()
        let passthroughLayer = ComputeLayer()
        texture.setTarget(passthroughLayer)
        passthroughLayer.setTarget(textureView)
        texture.processTexture()
    }
}
