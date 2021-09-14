import Foundation

struct XcodeVersionFormatter {
    func string(from xcode: XcodeApplication) -> String {
        let parts = [
            xcode.versionNumber,
            xcode.betaVersion.map { $0 == "0" ? "beta" : "beta \($0)" }
        ]
        
        return parts.compactMap { $0 }.joined(separator: " ")
    }
}
