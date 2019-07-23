import UIKit
import ToneKit

private enum ExampleCategories: Int, CaseIterable {
    case adjustments
    case blendModes

    enum Adjustments: Int, CaseIterable {
        case brightness
        case lookup
        case passThrough
        case whiteBalance

        var name: String {
            switch self {
            case .brightness:   return "Brightness"
            case .lookup:       return "Lookup"
            case .passThrough:  return "Pass Through"
            case .whiteBalance: return "White Balance"
            }
        }
    }

    enum BlendModes: Int, CaseIterable {
        case alpha
        case colorDodge
        case darken
        case hardLight
        case lighten
        case linearDodge
        case multiply
        case overlay
        case screen
        case softLight

        var name: String {
            switch self {
            case .alpha:       return "Alpha"
            case .colorDodge:  return "Color Dodge"
            case .darken:      return "Darken"
            case .hardLight:   return "Hard Light"
            case .lighten:     return "Lighten"
            case .linearDodge: return "Linear Dodge"
            case .multiply:    return "Multiply"
            case .overlay:     return "Overlay"
            case .screen:      return "Screen"
            case .softLight:   return "Soft Light"
            }
        }

        var computeLayer: ComputeLayer {
            switch self {
            case .alpha:       return AlphaBlendLayer()
            case .colorDodge:  return ColorDodgeBlendLayer()
            case .darken:      return DarkenBlendLayer()
            case .hardLight:   return HardLightBlendLayer()
            case .lighten:     return LightenBlendLayer()
            case .linearDodge: return LinearDodgeBlendLayer()
            case .multiply:    return MultiplyBlendLayer()
            case .overlay:     return OverlayBlendLayer()
            case .screen:      return ScreenBlendLayer()
            case .softLight:   return SoftLightBlendLayer()
            }
        }
    }
}

class ExampleSelectionViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private let cellReuseIdentifier = "CellReuseIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

extension ExampleSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ExampleCategories.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch ExampleCategories(rawValue: section)! {
        case .adjustments: return "Adjustments"
        case .blendModes:  return "Blend Modes"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ExampleCategories(rawValue: section)! {
        case .adjustments: return ExampleCategories.Adjustments.allCases.count
        case .blendModes:  return ExampleCategories.BlendModes.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        switch ExampleCategories(rawValue: indexPath.section)! {
        case .adjustments: cell.textLabel?.text = ExampleCategories.Adjustments(rawValue: indexPath.row)?.name
        case .blendModes:  cell.textLabel?.text = ExampleCategories.BlendModes(rawValue: indexPath.row)?.name
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch ExampleCategories(rawValue: indexPath.section)! {
        case .adjustments:
            presentExample(adjustment: ExampleCategories.Adjustments(rawValue: indexPath.row)!)
        case .blendModes:
            presentExample(blendMode: ExampleCategories.BlendModes(rawValue: indexPath.row)!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func presentExample(adjustment: ExampleCategories.Adjustments) {
        let viewController = ExampleEditViewController()
        viewController.navigationItem.title = adjustment.name
        switch adjustment {
        case .brightness:
            let brightnessLayer = BrightnessLayer()
            viewController.computeLayer = brightnessLayer
            viewController.configureSingleSlider {
                $0.minimumValue = -0.3
                $0.maximumValue = 0.3
            }
            viewController.configureTopSliderValueDidChange { value in
                brightnessLayer.intensity = value
            }
        case .lookup:
            let lookupLayer = LookupLayer(lookupImage: "sample_lookup.png")
            viewController.computeLayer = lookupLayer
            viewController.configureSingleSlider {
                $0.minimumValue = 0.0
                $0.maximumValue = 1.0
                $0.value = 1.0
            }
            viewController.configureTopSliderValueDidChange { value in
                lookupLayer.intensity = value
            }
        case .passThrough:
            viewController.computeLayer = ComputeLayer()
        case .whiteBalance:
            let whiteBalanceLayer = WhiteBalanceLayer()
            viewController.computeLayer = whiteBalanceLayer
            viewController.configureDoubleSliders {
                $0.minimumValue = -0.7
                $0.maximumValue = 1.2
                $1.minimumValue = 0.0
                $1.maximumValue = 1.0
            }
            viewController.configureTopSliderValueDidChange { value in
                whiteBalanceLayer.temperature = value
            }
            viewController.configureBottomSliderValueDidChange { value in
                whiteBalanceLayer.tint = value
            }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func presentExample(blendMode: ExampleCategories.BlendModes) {
        let viewController = ExampleEditViewController()
        viewController.navigationItem.title = blendMode.name
        let blendLayer = blendMode.computeLayer
        blendLayer.intensity = 1.0
        switch blendMode {
        case .alpha:
            let blendTexture: ImageTexture!
            blendTexture = ImageTexture(image: UIImage(named: "sample_image_2")!,
                                        options: ImageTexture.defaultOptions)
            blendTexture.setTarget(blendLayer, at: 1)
            blendTexture.processTexture()
        default:
            let solidColorLayer = SolidColorLayer(color: UIColor(hex: 0x6BA0DF))
            solidColorLayer.setOutputSize(size: MTLSize(width: 100, height: 100, depth: 1))
            solidColorLayer.setTarget(blendLayer, at: 1)
            solidColorLayer.renderTexture()
        }
        viewController.computeLayer = blendLayer
        viewController.configureSingleSlider {
            $0.minimumValue = 0.0
            $0.maximumValue = 1.0
            $0.value = 1.0
        }
        viewController.configureTopSliderValueDidChange { value in
            blendLayer.intensity = value
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}
