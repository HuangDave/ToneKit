import Metal

public protocol TextureOutput: AnyObject {
    var target: TextureInput? { get set }
    var targetIndex: UInt { get set }
    var outputTexture: MTLTexture? { get }
    var outputSize: MTLSize { get }
    var isDirty: Bool { get set }

    func setTarget(_ target: TextureInput, at index: UInt)
    func process()
}

extension TextureOutput {
    public func setTarget(_ target: TextureInput, at index: UInt = 0) {
        self.target = target
        self.targetIndex = index
    }
}
