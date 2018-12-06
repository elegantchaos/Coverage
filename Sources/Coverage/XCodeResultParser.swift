// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct ActionResult {
    let coveragePath: URL
}

class XCodeResultParser {
    func parse(results url: URL) -> ActionResult? {
        let infoURL = url.appendingPathComponent("Info.plist")
        if let info = NSDictionary(contentsOf: infoURL) {
            if let actions = info["Actions"] as? [[String:Any]] {
                for action in actions {
                    if let result = action["ActionResult"] as? [String:Any] {
                        if let coveragePath = result["CodeCoveragePath"] as? String {
                            return ActionResult(coveragePath: url.appendingPathComponent(coveragePath))
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
