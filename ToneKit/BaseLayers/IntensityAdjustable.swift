public protocol IntensityAdjustable {
    var intensity: Float { get set }
}

extension IntensityAdjustable where Self : ComputeLayer {
    public var intensity: Float {
        get { return uniforms.intensity!.value }
        set {
            uniforms.intensity!.value = newValue
            isDirty = true
        }
    }
}
