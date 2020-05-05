import UIKit
import ToneKit

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
    return ExampleCategory.allCases.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch ExampleCategory(rawValue: section)! {
    case .adjustments: return "Adjustments"
    case .blendModes:  return "Blend Modes"
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch ExampleCategory(rawValue: section)! {
    case .adjustments: return ExampleCategory.Adjustments.allCases.count
    case .blendModes:  return ExampleCategory.BlendModes.allCases.count
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
    switch ExampleCategory(rawValue: indexPath.section)! {
    case .adjustments:
      cell.textLabel?.text = ExampleCategory.Adjustments(rawValue: indexPath.row)?.name
    case .blendModes:
      cell.textLabel?.text = ExampleCategory.BlendModes(rawValue: indexPath.row)?.name
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch ExampleCategory(rawValue: indexPath.section)! {
    case .adjustments:
      presentExample(adjustment: ExampleCategory.Adjustments(rawValue: indexPath.row)!)
    case .blendModes:
      presentExample(blendMode: ExampleCategory.BlendModes(rawValue: indexPath.row)!)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

  private func presentExample(adjustment: ExampleCategory.Adjustments) {
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
      let lookupLayer = LookupLayer(lookupImageNamed: "sample_lookup.png")
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
      viewController.disableAllSliders()
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

  private func presentExample(blendMode: ExampleCategory.BlendModes) {
    let blendLayer = blendMode.computeLayer
    guard var intensityAdjustableLayer = blendLayer as? IntensityAdjustable else {
      fatalError()
    }
    intensityAdjustableLayer.intensity = 1.0

    let viewController = ExampleEditViewController()
    viewController.navigationItem.title = blendMode.name
    viewController.computeLayer = blendLayer
    viewController.configureSingleSlider {
      $0.minimumValue = 0.0
      $0.maximumValue = 1.0
      $0.value = 1.0
    }
    viewController.configureTopSliderValueDidChange { value in
      intensityAdjustableLayer.intensity = value
    }

    switch blendMode {
    case .alpha:
      let blendTexture: ImageTexture!
      blendTexture = ImageTexture(image: UIImage(named: "sample_image_2")!,
                                  options: ImageTexture.defaultOptions)
      blendTexture.setTarget(blendLayer, at: 1)
      blendTexture.process()
    default:
      let solidColorLayer = SolidColorLayer(color: UIColor(hex: 0x6BA0DF))
      solidColorLayer.setOutputSize(size: MTLSize(width: 100, height: 100, depth: 1))
      solidColorLayer.setTarget(blendLayer, at: 1)
      solidColorLayer.render()
    }
    navigationController?.pushViewController(viewController, animated: true)
  }
}
