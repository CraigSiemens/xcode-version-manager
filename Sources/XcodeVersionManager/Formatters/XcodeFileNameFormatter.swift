import Foundation

struct XcodeFileNameFormatter {
    func string(from xcode: XcodeApplication) -> String {
        let parts = [
            "Xcode",
            xcode.versionNumber,
            xcode.betaVersion.map { $0 == "0" ? "beta" : "beta-\($0)" },
        ]
        
        return parts.compactMap { $0 }
            .joined(separator: "-")
            .map { CharacterSet.alphanumerics.contains($0) ? String($0) : "-" }
            .joined()
    }
}
