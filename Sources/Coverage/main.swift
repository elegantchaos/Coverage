import Foundation
import Runner

//let path = "/Users/sam/Library/Developer/Xcode/DerivedData/BookishModel-fmiwhpkahlvxvehgajbipuidfmec/Logs/Test/Test-BookishModelMac-2018.12.06_15-15-22-+0000.xcresult/1_Test/action.xccovreport"


let path = "/Users/sam/Library/Developer/Xcode/DerivedData/BookishModel-fmiwhpkahlvxvehgajbipuidfmec/Logs/Test/Test-BookishModelMac-2018.12.06_15-15-22-+0000.xcresult"
//let infoURL = URL(fileURLWithPath: path).appendingPathComponent("Info.plist")
//if let info = NSDictionary(contentsOf: infoURL) {
//    if let actions = info["Actions"] as? [[String:Any]] {
//        for action in actions {
//            if let result = action["ActionResult"] as? [String:Any] {
//                if let coveragePath = result["CodeCoveragePath"] as? String {
//                    print(coveragePath)
//                }
//            }
//        }
//    }
//}


func report(for url: URL, target: String? = nil) {
    let xcrunURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    let runner = Runner(for: xcrunURL)
    
    if let result = try? runner.sync(arguments: ["xccov", "view", url.path, "--json"]), result.status == 0 {
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

let parser = XCodeResultParser()
if let results = parser.parse(results: URL(fileURLWithPath: path)) {
    report(for: results.coveragePath, target: "BookishModel")
}

