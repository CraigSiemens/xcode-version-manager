import XCTest

import XcodeVersionManagerTests
import TableKitTests

var tests = [XCTestCaseEntry]()
tests += XcodeVersionManagerTests.allTests()
tests += TableKitTests.allTests()
XCTMain(tests)
