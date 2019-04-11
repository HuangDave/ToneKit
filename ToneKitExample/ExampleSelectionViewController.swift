import UIKit
import ToneKit

class ExampleSelectionViewController: UIViewController {
    private enum ExampleOptions: Int, CaseIterable {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExampleOptions.allCases.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        guard let option = ExampleOptions(rawValue: indexPath.row) else {
            fatalError("")
        }
        cell.textLabel?.text = option.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = ExampleOptions(rawValue: indexPath.row) else {
            fatalError("")
        }
        let viewController = ExampleEditViewController()
        viewController.navigationItem.title = option.name
        switch option {
        case .brightness:
            let brightnessLayer = BrightnessLayer()
            viewController.computeLayer = brightnessLayer
            viewController.configureSingleSlider {
                $0.minimumValue = -0.3
                $0.maximumValue = 0.3
                $0.value = 0.0
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
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
