import Metal

import Nimble
import SwiftyMocky
import Quick

@testable import ToneKit

class UniformSettingsSpec: QuickSpec {
  var uniformSettings: UniformSettings!

  override func spec() {
    describe("UniformSettings Tests") {
      var uniformSettings: UniformSettings!

      beforeEach {
        uniformSettings = UniformSettings()
      }

      it("Should register a UniformBufferable") {
        let testKey = "MockUniform"
        let expectedUniformsListCount = 1
        let expectedBufferCount = 3
        let expectedBufferSize = MemoryLayout<Float>.size

        let mockUniform = UniformBufferableMock()
        mockUniform.given(.label(getter: testKey))
        mockUniform.given(.bufferCount(getter: expectedBufferCount))
        mockUniform.given(.bufferSize(getter: expectedBufferSize))

        expect(uniformSettings.uniformsList.count).to(equal(0))

        uniformSettings.register(uniform: mockUniform, withKey: testKey)

        expect(uniformSettings.uniformsList.count).to(equal(expectedUniformsListCount))
        expect(uniformSettings.uniforms[testKey]??.label).to(match(mockUniform.label))
        expect(uniformSettings.uniformsList.first?.bufferCount).to(equal(expectedBufferCount))
        expect(uniformSettings.uniformsList.first?.bufferSize).to(equal(expectedBufferSize))
      }

      describe("Given a uniform with type Float") {
        let testKey = "FloatUniform"
        let expectedBufferCount = 3
        let expectedValue: Float = 2.8

        var floatUniform: Uniform<Float>!

        beforeEach {
          floatUniform = Uniform<Float>(label: testKey,
                                        bufferCount: expectedBufferCount,
                                        initialValue: expectedValue)
          uniformSettings.register(uniform: floatUniform, withKey: testKey)
        }

        it("the dynamic lookup should return the uniform as type Float") {
          let uniform: Uniform<Float>? = uniformSettings.FloatUniform
          expect(uniform).toNot(beNil())
          expect(uniform!.value).to(equal(expectedValue))
        }
      }
    }
  }
}
