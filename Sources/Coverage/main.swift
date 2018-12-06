import Foundation
import Runner



let path = "/Users/sam/Library/Developer/Xcode/DerivedData/BookishModel-fmiwhpkahlvxvehgajbipuidfmec/Logs/Test/Test-BookishModelMac-2018.12.06_15-15-22-+0000.xcresult/1_Test/action.xccovreport"
let url = URL(fileURLWithPath: path)

let xcrunURL = URL(fileURLWithPath: "/usr/bin/xcrun")
let runner = Runner(for: xcrunURL)

func report(for path: String, target: String? = nil) {
    if let result = try? runner.sync(arguments: ["xccov", "view", path, "--json"]), result.status == 0 {
        let parser = Parser()
        if let report = parser.parse(result.stdout) {
            for target in report.targets {
                print(target.name)
                for file in target.files {
                    print("- \(file.name)")
                }
            }
        }
    }
}

report(for: path, target: "BookishModel")

