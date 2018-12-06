import XCTest

import CoverageTests

var tests = [XCTestCaseEntry]()
tests += CoverageTests.allTests()
XCTMain(tests)
