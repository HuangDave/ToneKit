import Metal
import Dispatch

/// Metal device singleton for image processing.
public final class MetalDevice {
    public static let shared: MetalDevice = MetalDevice()

    private(set) public var device: MTLDevice!
    private(set) public var commandQueue: MTLCommandQueue!
    private(set) public var library: MTLLibrary!
    private(set) public var processingQueue: DispatchQueue

    private init() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        do {
            library = try device.makeLibrary(filepath: Bundle(for: MetalDevice.self)
                .path(forResource: "default", ofType: "metallib")!)
        } catch {
            fatalError("Unable to create shader library: \(error)")
        }
        processingQueue = DispatchQueue(label: "com.ToneKit.ProcessingQueue")
    }

    func makeFunction(name: String) -> MTLFunction {
        guard let function = library.makeFunction(name: name) else {
            fatalError("The function \(name) does not exist in the library!")
        }
        return function
    }
}
