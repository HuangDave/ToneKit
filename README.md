# ToneKit
ToneKit is a lightweight image processing framework written in Swift.

## Requirements
- Swift: 5.0+
- iOS: 10+
- Xcode: 11+

## Installation
1. File -> Swift Packages -> Add Package Dependency...
2. Enter `https://github.com/HuangDave/ToneKit.git` in the search field.
3. Select Branch in Rules and set to `spm_compatible`.
4. Add `ToneKit` in `Framework, Libraries, and Embedded Content` and set to
   Embed & Sign

## Example Usage
### Adding Your Own Compute Kernel Shader
```c++
// MyShader.metal
#include <metal_stdlib>
using namespace metal;

kernel void MyShader(
  texture2d<float, access::sample> input_texture1 [[texture(0)]],
  texture2d<float, access::sample> input_texture2 [[texture(1)]],
  texture2d<float, access::write> output_texture [[texture(2)]],
  constant float & uniform1 [[buffer(0)]],
  constant float4 & uniform2 [[buffer(1)]],
  uint2 gid [[thread_position_in_grid]]);
```

```swift
import ToneKit
import simd

class MyComputeLayer: ComputeLayer {
  override var functionName: String { return "MyShader" }
  override var inputCount: UInt { return 2 }

  var setting1: Float {
    // UniformsSettings uses dynamic member lookup. The uniform value can be
    // accessed by its key set in registerUniforms()
    get { return uniforms.uniform1!.value }
    set {
      uniforms.uniform1!.value = newValue
      isDirty = true
    }
  }

  var setting2: SIMD4<Float> {
    get { return uniforms.someUniformName!.value }
    set {
      uniforms.someUniformName!.value = newValue
      isDirty = true
    }
  }

  override func registerUniforms() {
    // Register uniforms in the same order as the shader arguments
    uniforms.register(uniform: Uniform<Float>(initialValue: 1.0),
                      withKey: "uniform1")
    uniforms.register(
     uniform: Uniform<SIMD4<Float>>(initialValue: SIMD4<Float>(repeating: 0.0)),
     withKey: "someUniformName")
  }
}

let inputTexture1 = ImageTexture(image: image1)
let inputTexture2 = ImageTexture(image: image2)
let layer = MyComputeLayer()
inputTexture1.setTarget(layer)
inputTexture2.setTarget(layer, at: 1)
inputTexture2.process()

layer.setting1 = 0.3
layer.setting2 = 0.95

inputTexture1.process()
```

### Displaying a Texture
```swift
import ToneKit

let textureView = TextureView(frame: .zero)
let texture = ImageTexture(image: UIImage(named: image)!)

texture.setTarget(textureView)
texture.process()
```

**NOTE:** *Currently the Swift Package Manager does not support use of
Resources. The required shaders should be included in your own project.*
