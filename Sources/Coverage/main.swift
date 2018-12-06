import Foundation
import Runner

struct File: Decodable {
    let coveredLines: Int
    let lineCoverage: Double
    let path: String
    let name: String
    let executableLines: Int
}

struct Target: Decodable {
    let coveredLines: Int
    let lineCoverage: Double
    let name: String
    let files: [File]
}

struct Report: Decodable {
    let coveredLines: Int
    let lineCoverage: Double
    let targets: [Target]
}

let path = "/Users/sam/Library/Developer/Xcode/DerivedData/BookishModel-fmiwhpkahlvxvehgajbipuidfmec/Logs/Test/Test-BookishModelMac-2018.12.06_15-15-22-+0000.xcresult/1_Test/action.xccovreport"
let url = URL(fileURLWithPath: path)

let xcrunURL = URL(fileURLWithPath: "/usr/bin/xcrun")
let runner = Runner(for: xcrunURL)

if let result = try? runner.sync(arguments: ["xccov", "view", path, "--json"]), result.status == 0 {
    if let data = result.stdout.data(using: String.Encoding.utf8) {
//        if let parsed = try? JSONSerialization.jsonObject(with: data, options: []) {
//            print(parsed["coveredLines"])
//            print(parsed)
//        }
//    }
        
        let decoder = JSONDecoder()
        if let parsed = try? decoder.decode(Report.self, from: data) {
            for target in parsed.targets {
                print(target.name)
                for file in target.files {
                    print("- \(file.name)")
                }
            }
        }
    }
}


// "xcrun xccov view /Users/sam/Library/Developer/Xcode/DerivedData/BookishModel-fmiwhpkahlvxvehgajbipuidfmec/Logs/Test/Test-BookishModelMac-2018.12.06_15-15-22-+0000.xcresult/1_Test/action.xccovreport --json | jsonlint -p > report.json"

