import ToneKit

protocol IntensityAdjustable {
  var intensity: Float { get set }
}

extension IntensityAdjustable where Self : ComputeLayer {
  var intensity: Float {
    get { return uniforms.intensity!.value }
    set {
      uniforms.intensity!.value = newValue
      isDirty = true
    }
  }
}

extension AlphaBlendLayer: IntensityAdjustable {}
extension ColorDodgeBlendLayer: IntensityAdjustable {}
extension DarkenBlendLayer: IntensityAdjustable {}
extension HardLightBlendLayer: IntensityAdjustable {}
extension LightenBlendLayer: IntensityAdjustable {}
extension LinearDodgeBlendLayer: IntensityAdjustable {}
extension MultiplyBlendLayer: IntensityAdjustable {}
extension OverlayBlendLayer: IntensityAdjustable {}
extension ScreenBlendLayer: IntensityAdjustable {}
extension SoftLightBlendLayer: IntensityAdjustable {}
