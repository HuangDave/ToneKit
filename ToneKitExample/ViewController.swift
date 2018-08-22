//
//  ViewController.swift
//  ToneKitExample
//
//  Created by DAVID HUANG on 9/6/18.
//

import UIKit
import ToneKit

class ViewController: UIViewController {
    @IBOutlet weak var textureView: TextureView!

    var texture: ImageTexture = ImageTexture(image:   UIImage(named: "sample_image_1")!,
                                             options: ImageTexture.defaultOptions)

    override func viewDidLoad() {
        super.viewDidLoad()
        texture.setTarget(textureView)
        texture.processTexture()
    }
}

