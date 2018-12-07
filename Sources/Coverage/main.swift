import Foundation
import Runner
import Arguments

let documentation = """
Interpret XCode code coverage results.

Usage:
    coverage <results-path> [<target>] [--showFiles] [--threshold=<amount>]
    coverage --help

Arguments:
    <results-path>        Path to the xcode results file.

    <target>              The target to produce output for. If this is missing, output is produced for all targets.

Options:
    --showFiles           Show coverage results for each file in the target(s).
    --threshold=<amount>  Tf coverage is below this threshold, we will return a non-zero error code.

Exit Status:

    The coverage command exits with one of the following values:

    0   If the arguments were ok and the threshold was met (or not specified).
    1   If there was an error parsing the arguments.
    2   If the threshold wasn't met.


"""

enum ReturnCode: Int32 {
    case ok = 0
    case badArguments = 1
    case missedThreshold = 2
}

func report(for url: URL, target filter: String = "", showFiles: Bool = false, threshold: Double = 0) -> ReturnCode {
    var status = ReturnCode.ok
    let xcrunURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    let runner = Runner(for: xcrunURL)
    
    if let result = try? runner.sync(arguments: ["xccov", "view", url.path, "--json"]), result.status == 0 {
        let parser = CodeCoverageParser()
        if let report = parser.parse(result.stdout) {
            let noFilter = filter == ""
            let showTargetNames = noFilter && report.targets.count > 1
            for target in report.targets {
                let simpleName = URL(string: target.name)!.deletingPathExtension().path
                if noFilter || (filter == simpleName) || (filter == target.name) {
                    if showFiles {
                        for file in target.files {
                            print("\(file.name): \(file.lineCoverage)")
                            if file.lineCoverage < threshold {
                                status = .missedThreshold
                            }
                        }
                    } else {
                        if showTargetNames {
                            print("\(target.name): \(target.lineCoverage)")
                        } else {
                            print(target.lineCoverage)
                        }

                        if target.lineCoverage < threshold {
                            status = .missedThreshold
                        }
                    }
                }
            }
        }
    }
    return status
}

let a = Arguments(documentation: documentation, version: "1.0")
let path = a.argument("results-path")
let target = a.argument("target")
let showFiles = a.flag("showFiles")
let thresholdString = a.option("threshold") ?? "0"
let threshold = (thresholdString as NSString).doubleValue
let parser = XCodeResultParser()
let result: ReturnCode
if let results = parser.parse(results: URL(fileURLWithPath: path)) {
    result = report(for: results.coveragePath, target: target, showFiles: showFiles, threshold: threshold)
} else {
    result = .badArguments
}

exit(result.rawValue)

