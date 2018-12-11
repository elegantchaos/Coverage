import Foundation
import Runner
import Arguments

let documentation = """
Interpret XCode code coverage results.

Usage:
    coverage <results-path> [<target>] [--printFiles] [--printTargets] [--threshold=<amount>]
    coverage --help

Arguments:
    <results-path>        Path to the xcode results file.

    <target>              The target to produce output for. If this is missing, output is produced for all targets.

Options:
    --printFiles          Print coverage results for each file in the target(s).
    --printTargets        Print coverage results for the target(s).
    --threshold=<amount>  Tf coverage is below this threshold, we will return a non-zero error code.

Exit Status:

    The coverage command exits with one of the following values:

    0   If the arguments were ok and the threshold was met (or not specified).
    1   If there was an error parsing the arguments.
    2   If the threshold wasn't met.


"""

enum ReturnCode: Int32 {
    case ok = 0
    case badArguments = 100
    case missedThreshold = 101
}

func report(for url: URL, target filter: String = "", showFiles: Bool = false, showTargets: Bool = false, threshold: Double = 0) -> ReturnCode {
    var status = ReturnCode.ok
    let xcrunURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    let runner = Runner(for: xcrunURL)
    
    if let result = try? runner.sync(arguments: ["xccov", "view", url.path, "--json"]), result.status == 0 {
        let parser = CodeCoverageParser()
        if let report = parser.parse(result.stdout) {
            let noFilter = filter == ""
            var matchedFilter = false
            for target in report.targets {
                let simpleName = URL(string: target.name)!.deletingPathExtension().path
                if noFilter || (filter == simpleName) || (filter == target.name) {
                    matchedFilter = true
                    if showTargets {
                        print("\n\(target.name): \(target.lineCoverage)")
                    }

                    let thresholdPC = Int(threshold * 100.0)
                    if showFiles {
                        for file in target.files {
                            let indent = showTargets ? "- " : ""
                            print("\(indent)\(file.name): \(file.lineCoverage)")
                            if file.lineCoverage < threshold {
                                status = .missedThreshold
                                let targetPC = Int(file.lineCoverage * 100.0)
                                print("File \(file.name) misses the coverage threshold of \(thresholdPC)% with \(targetPC)%.")
                            }
                        }
                    } else {

                        let targetPC = Int(target.lineCoverage * 100.0)
                        if target.lineCoverage < threshold {
                            status = .missedThreshold
                            print("Target \(simpleName) misses the coverage threshold of \(thresholdPC)% with \(targetPC)%.")
                        } else if threshold > 0 {
                            print("Target \(simpleName) passes the coverage threshold of \(thresholdPC)% with \(targetPC)%.")
                        }
                    }
                }
            }
            if !matchedFilter {
                if noFilter {
                    print ("Failed to find any targets.")
                } else {
                    print("Failed to find target \(filter).")
                }
            }
        }
    }
    
    return status
}

let a = Arguments(documentation: documentation, version: "1.0")
let path = a.argument("results-path")
let target = a.argument("target")
let showFiles = a.flag("printFiles")
let showTargets = a.flag("printTargets")
let thresholdString = a.option("threshold") ?? "0"
let threshold = (thresholdString as NSString).doubleValue
let parser = XCodeResultParser()
let result: ReturnCode
if let results = parser.parse(results: URL(fileURLWithPath: path)) {
    result = report(for: results.coveragePath, target: target, showFiles: showFiles, showTargets: showTargets, threshold: threshold)
} else {
    result = .badArguments
}

exit(result.rawValue)

