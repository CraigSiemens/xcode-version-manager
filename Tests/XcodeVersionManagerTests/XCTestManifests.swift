import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(XcodeVersionManagerTests.allTests),
    ]
}
#endif
