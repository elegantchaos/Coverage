import XCTest
import class Foundation.Bundle

final class CoverageTests: XCTestCase {
    
    func runCoverage(_ extraArguments: [String], results: URL? = nil) throws -> (Int32, String?) {
        guard #available(macOS 10.13, *) else {
            return (0, nil)
        }
        
        let products = productsDirectory
        let fooBinary = products.appendingPathComponent("coverage")
        var arguments = [results?.path ?? exampleResults.path]
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
        return (process.terminationStatus, output)
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

    func testBadArgs() throws {
        let (status, _) = try runCoverage(["Coverage", "Bad Argument"])
        XCTAssertEqual(status, 2)
    }

    func testMissingResults() throws {
        let (status, _) = try runCoverage(["Coverage"], results: URL(fileURLWithPath: "/"))
        XCTAssertEqual(status, )
    }
    

    func testFailingThreshold() throws {
        let (status, output) = try runCoverage(["Coverage", "--threshold=0.5"])
        XCTAssertEqual(status, 101)
        XCTAssertEqual(output, "Target Coverage misses the coverage threshold of 50% with 18%.\n")
    }
    
    func testPassingThreshold() throws {
        let (status, output) = try runCoverage(["Coverage", "--threshold=0.1"])
        XCTAssertEqual(status, 0)
        XCTAssertEqual(output, "Target Coverage passes the coverage threshold of 10% with 18%.\n")
    }

}
