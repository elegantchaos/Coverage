// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct ActionResult {
    let coverageURL: URL
}

class XCodeResultParser {
    func parse(results url: URL) -> ActionResult? {
        let infoURL = url.appendingPathComponent("Info.plist")
        if let info = NSDictionary(contentsOf: infoURL) {
            if let actions = info["Actions"] as? [[String:Any]] {
                for action in actions {
                    if let result = action["ActionResult"] as? [String:Any] {
                        if let coveragePath = result["CodeCoveragePath"] as? String {
                            // Prior to Xcode 10.2, there's an explicit entry for the code coverage path
                            return ActionResult(coverageURL: url.appendingPathComponent(coveragePath))
                        } else if let hasCoverage = result["HasCodeCoverage"] as? Bool, hasCoverage, let logPath = result["LogPath"] as? String {
                            // Xcode 10.2 produces a slightly different result dictionary, so we're making some assumptions about
                            // the location of the coverage file, relative to the location of the log.
                            let logURL = url.appendingPathComponent(logPath)
                            let coverageURL = logURL.deletingLastPathComponent().appendingPathComponent("action.xccovreport")
                            return ActionResult(coverageURL: coverageURL)
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
