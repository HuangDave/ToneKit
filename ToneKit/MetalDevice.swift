import Dispatch
import Metal

public final class MetalDevice {
  public static let shared = MetalDevice()

  private(set) public var device: MTLDevice!
  private(set) public var commandQueue: MTLCommandQueue!
  private(set) public var library: MTLLibrary!
  private(set) public var processingQueue: DispatchQueue

  private init() {
    device = MTLCreateSystemDefaultDevice()
    commandQueue = device.makeCommandQueue()

    let bundle = Bundle(for: MetalDevice.self)
    if let libraryPath = bundle.path(forResource: "default", ofType: "metallib") {
      do {
        library = try device.makeLibrary(filepath: libraryPath)
      } catch {
        fatalError("Could not get shader library from \(libraryPath)")
      }
    } else {
      guard let library = device.makeDefaultLibrary() else {
        fatalError("Need atleast one .metal shader file in project")
      }
      self.library = library
    }
    library.label = "default.metallib"
    processingQueue = DispatchQueue(label: "com.ToneKit.ProcessingQueue")
  }

  func makeFunction(
    name: String,
    fromLibrary library: MTLLibrary = MetalDevice.shared.library
  ) -> MTLFunction {
    guard let function = library.makeFunction(name: name) else {
      fatalError("The function: \(name) does not exist in \(String(describing: library.label))!")
    }
    return function
  }
}
