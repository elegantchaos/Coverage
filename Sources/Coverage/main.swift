import Foundation
import Runner
import Arguments

func report(for url: URL, target filter: String? = nil, showFiles: Bool = false) {
    let xcrunURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    let runner = Runner(for: xcrunURL)
    
    if let result = try? runner.sync(arguments: ["xccov", "view", url.path, "--json"]), result.status == 0 {
        let parser = Parser()
        if let report = parser.parse(result.stdout) {
            for target in report.targets {
                if (filter == nil) || (filter! == target.name) {
                    if showFiles {
                        for file in target.files {
                            print("- \(file.name): \(file.lineCoverage)")
                        }
                    } else {
                        print(target.lineCoverage)
                    }
                }
            }
        }
    }
}

let documentation = """
Interpret XCode code coverage results.

Usage:
    coverage <results-path> [<target>] [--showFiles]

Arguments:
    <results-path>        Path to the xcode results file.

    <target>              The target to produce output for. If this is missing, output is produced for all targets.

Options:
    --showFiles           Show coverage results for each file in the target(s).
"""

let a = Arguments(documentation: documentation, version: "1.0")
let path = a.argument("results-path")
let target = a.argument("target")
let showFiles = CommandLine.arguments.contains("--showFiles")

let parser = XCodeResultParser()
if let results = parser.parse(results: URL(fileURLWithPath: path)) {
    report(for: results.coveragePath, target: target, showFiles: showFiles)
}

