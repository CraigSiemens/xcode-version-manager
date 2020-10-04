import Foundation

struct XcodeApplication {
    let url: URL
    
    let versionNumber: String
    let buildNumber: String
    
    init(url: URL) throws {
        self.url = url
        
        let arguments = [
            "-c", "Print CFBundleShortVersionString",
            "-c", "Print ProductBuildVersion",
            url.absoluteURL
                .appendingPathComponent("Contents")
                .appendingPathComponent("version.plist")
                .path
        ]
        
        let results = try Process.execute("/usr/libexec/PlistBuddy", arguments: arguments)
        
        let parts = String(decoding: results, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
        
        self.versionNumber = String(parts[0])
        self.buildNumber = String(parts[1])
    }
}

extension XcodeApplication {
    func use() throws {
        let arguments = [
            "-s",
            url.absoluteURL
                .appendingPathComponent("Contents")
                .appendingPathComponent("Developer")
                .path
        ]

        let results = try Process.execute("/usr/bin/xcode-select", arguments: arguments)

        print(results)
    }
}

// MARK: - Comparable
extension XcodeApplication: Comparable {
    static func < (lhs: XcodeApplication, rhs: XcodeApplication) -> Bool {
        let versionResult = lhs.versionNumber.compare(rhs.versionNumber, options: .numeric)
        return versionResult == .orderedAscending
            || versionResult == .orderedSame
            && lhs.buildNumber.compare(rhs.buildNumber, options: .numeric) == .orderedAscending
    }
}

// MARK: All
extension XcodeApplication {
    static func all() throws -> [XcodeApplication] {
        let urls = LSCopyApplicationURLsForBundleIdentifier("com.apple.dt.Xcode" as CFString, nil)?
            .takeUnretainedValue()
            as? [URL]
        
        return try (urls ?? [])
            .map { try XcodeApplication(url: $0) }
    }
}
