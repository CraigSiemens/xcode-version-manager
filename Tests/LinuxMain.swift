import XCTest

import xcode_version_managerTests
import TableKitTests

var tests = [XCTestCaseEntry]()
tests += XcodeVersionManagerTests.allTests()
tests += TableKitTests.allTests()
XCTMain(tests)
