
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

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

class Parser {
    func parse(_ string: String) -> Report? {
        if let data = string.data(using: String.Encoding.utf8) {
            let decoder = JSONDecoder()
            if let parsed = try? decoder.decode(Report.self, from: data) {
                return parsed
            }
        }
        
        return nil
    }
}
