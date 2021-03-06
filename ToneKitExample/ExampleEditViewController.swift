import UIKit
import ToneKit

class ExampleEditViewController: UIViewController {
    private let textureView: TextureView = {
        let view = TextureView(frame: .zero)
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let topSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    private let bottomSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private var topSliderValueDidChangeHandler: ((Float) -> Void)?
    private var bottomSliderValueDidChangeHandler: ((Float) -> Void)?

    var texture: ImageTexture = ImageTexture(image:   UIImage(named: "sample_image_1")!,
                                             options: ImageTexture.defaultOptions)
    var computeLayer: ComputeLayer!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextureView()
        setupAdjustmentSliders()
        view.layoutIfNeeded()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(userDidSelectSaveImage))

        texture.setTarget(computeLayer)
        computeLayer.setTarget(textureView)
        texture.process()
    }

    private func setupTextureView() {
        view.addSubview(textureView)
        NSLayoutConstraint.activate([
            textureView.topAnchor.constraint(equalTo: view.topAnchor),
            textureView.leftAnchor.constraint(equalTo: view.leftAnchor),
            textureView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textureView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
    }

    private func setupAdjustmentSliders() {
        let sliderStackView = UIStackView(arrangedSubviews: [topSlider, bottomSlider])
        sliderStackView.axis = .vertical
        sliderStackView.distribution = .fillEqually
        sliderStackView.spacing = 5.0
        sliderStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sliderStackView)

        topSlider.addTarget(self, action: #selector(topSliderValueDidChange), for: .valueChanged)
        bottomSlider.addTarget(self, action: #selector(bottomSliderValueDidChange), for: .valueChanged)

        NSLayoutConstraint.activate([
            sliderStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10.0),
            sliderStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30.0),
            sliderStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30.0),
            sliderStackView.heightAnchor.constraint(equalToConstant: 100.0)
        ])
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?,
                     contextInfo: UnsafeRawPointer) {
        var alertTitle: String = ""
        if error != nil {
            // we got back an error!
            alertTitle = "Unable to save image!"
        } else {
            alertTitle = "Saved!"
        }
        let alertViewController = UIAlertController(title: alertTitle,
                                                    message: "",
                                                    preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertViewController, animated: true)
    }

    @objc private func userDidSelectSaveImage() {
        UIImageWriteToSavedPhotosAlbum(textureView.texture!.uiImage(),
                                       self,
                                       #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
}
// MARK: - UISlider Adjustments Configurations
extension ExampleEditViewController {
    func disableAllSliders() {
        topSlider.isEnabled = false
        bottomSlider.isEnabled = false
        topSlider.isHidden = true
        bottomSlider.isHidden = true
    }

    func configureSingleSlider(block: (UISlider) -> Void) {
        bottomSlider.isEnabled = false
        bottomSlider.isHidden = true
        block(topSlider)
    }

    func configureDoubleSliders(block: (UISlider, UISlider) -> Void) {
        block(topSlider, bottomSlider)
    }

    func configureTopSliderValueDidChange(handler: ((Float) -> Void)?) {
        topSliderValueDidChangeHandler = handler
    }

    func configureBottomSliderValueDidChange(handler: ((Float) -> Void)?) {
        bottomSliderValueDidChangeHandler = handler
    }

    @objc private func topSliderValueDidChange(slider: UISlider) {
        topSliderValueDidChangeHandler?(slider.value)
        texture.process()
    }

    @objc private func bottomSliderValueDidChange(slider: UISlider) {
        bottomSliderValueDidChangeHandler?(slider.value)
        texture.process()
    }
}
