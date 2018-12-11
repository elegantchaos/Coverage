import XCTest
import class Foundation.Bundle

final class CoverageTests: XCTestCase {
    
    func runCoverage(_ extraArguments: [String]) throws -> String? {
        guard #available(macOS 10.13, *) else {
            return nil
        }
        
        let products = productsDirectory
        let fooBinary = products.appendingPathComponent("coverage")
        var arguments = [exampleResults.path]
        arguments.append(contentsOf: extraArguments)

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        return output
    }

    var exampleResults: URL {
        return URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("CoverageTests/ExampleData/Test.xcresult")
    }
    
    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }

    func testFailingThreshold() throws {
        let output = try runCoverage(["Coverage", "--threshold=0.5"])
        XCTAssertEqual(output, "Target Coverage misses the coverage threshold of 50% with 18%.\n")
    }
    
    func testPassingThreshold() throws {
        let output = try runCoverage(["Coverage", "--threshold=0.1"])
        XCTAssertEqual(output, "Target Coverage passes the coverage threshold of 10% with 18%.\n")
    }

}
