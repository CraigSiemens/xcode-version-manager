import XCTest
@testable import XcodeVersionManager

final class XcodeVersionManagerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(XcodeVersionManager().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
