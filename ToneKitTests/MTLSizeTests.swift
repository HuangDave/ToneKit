import XCTest
@testable import ToneKit

class MTLSizeTests: XCTestCase {

    func test_MTLSizeZero() {
        let sizeZero = MTLSize.zero
        XCTAssertTrue(sizeZero.width  == 0)
        XCTAssertTrue(sizeZero.height == 0)
        XCTAssertTrue(sizeZero.depth  == 0)
    }

    func test_Equatable() {
        let a = MTLSize(width: 0, height: 0, depth: 0)
        let b = MTLSize.zero
        let c = MTLSize(width: 1, height: 2, depth: 3)

        XCTAssertTrue(a == b)
        XCTAssertFalse(b == c)
    }
}
