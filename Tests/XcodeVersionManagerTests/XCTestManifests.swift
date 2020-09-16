import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(xcode_version_managerTests.allTests),
    ]
}
#endif
