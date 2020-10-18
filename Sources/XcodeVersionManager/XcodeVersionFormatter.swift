import Foundation

struct XcodeVersionFormatter {
    func string(from xcode: XcodeApplication) -> String {
        let parts = [
            xcode.versionNumber,
            xcode.betaVersion.map { "beta \($0)" },
            "(\(xcode.buildNumber))"
        ]
        
        return parts.compactMap { $0 }.joined(separator: " ")
    }
}
