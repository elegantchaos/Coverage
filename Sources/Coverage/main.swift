import Foundation
import Runner

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

guard CommandLine.argc >= 2 else {
    fatalError("Usage: coverage <path-to-xcode-results> { <target> } { --showFiles }")
}

let path = CommandLine.arguments[1]
let target: String? = CommandLine.argc > 2 ? CommandLine.arguments[2] : nil
let showFiles = CommandLine.arguments.contains("--showFiles")

let parser = XCodeResultParser()
if let results = parser.parse(results: URL(fileURLWithPath: path)) {
    report(for: results.coveragePath, target: target, showFiles: showFiles)
}

