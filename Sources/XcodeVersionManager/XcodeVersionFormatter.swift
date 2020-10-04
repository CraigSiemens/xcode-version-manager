import Foundation

struct XcodeVersionFormatter {
    func string(from xcode: XcodeApplication) -> String {
        "\(xcode.versionNumber) (\(xcode.buildNumber))"
    }
}
