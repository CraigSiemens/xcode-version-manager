import Foundation
import ObjectiveC.runtime

struct XcodeApplication {
    let url: URL
    
    let versionNumber: String
    let buildNumber: String
    let betaVersion: String?
    
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
        
        let betaVersionResults = try? Process.execute(Bundle.main.executablePath!, arguments: ["beta-version-number", url.path])
        
        self.betaVersion = betaVersionResults
            .map {
                String(decoding: $0, as: UTF8.self)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .flatMap { $0.isEmpty ? nil : $0 }
    }
}

// MARK: - Use
extension XcodeApplication {
    func use() throws {
        let arguments = [
            "--switch",
            url.absoluteURL
                .appendingPathComponent("Contents")
                .appendingPathComponent("Developer")
                .path
        ]

        try Process.execute("/usr/bin/xcode-select", arguments: arguments)
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

// MARK: Current
extension XcodeApplication {
    static func current() throws -> XcodeApplication {
        let results = try Process.execute("/usr/bin/xcode-select", arguments: ["--print-path"])
        
        let path = String(decoding: results, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let url = URL(fileURLWithPath: path)
            .deletingLastPathComponent() // Developer
            .deletingLastPathComponent() // Contents
        
        return try XcodeApplication(url: url)
    }
}

// MARK: All
extension XcodeApplication {
    static func all() throws -> [XcodeApplication] {
        let urls = LSCopyApplicationURLsForBundleIdentifier("com.apple.dt.Xcode" as CFString, nil)?
            .takeUnretainedValue()
            as? [URL]
            ?? []
        
        return try urls.concurrentMap { try XcodeApplication(url: $0) }
//        return try urls.map { try XcodeApplication(url: $0) }
    }
}

// MARK: Beta Version
//extension XcodeApplication {
//    var betaVersion: String? {
//        guard let results = try? Process.execute("xcvm", arguments: ["beta-version-number", url.path]),
//            !results.isEmpty else {
//                return nil
//        }
//
//        return String(decoding: results, as: UTF8.self)
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//}
