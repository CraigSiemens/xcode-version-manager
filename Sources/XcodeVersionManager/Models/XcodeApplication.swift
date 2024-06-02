import Foundation

struct XcodeApplication: Encodable {
    let url: URL
    
    let versionNumber: String
    let buildNumber: String
    let betaVersion: String?
    
    init(url: URL) throws {
        self.url = url
        
        let versionNumberResults = try Process.execute(
            "/usr/libexec/PlistBuddy",
            arguments: [
                "-c", "Print CFBundleShortVersionString",
                "-c", "Print ProductBuildVersion",
                url.absoluteURL
                    .appendingPathComponent("Contents")
                    .appendingPathComponent("version.plist")
                    .path
            ]
        )
        
        let parts = String(decoding: versionNumberResults, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
        
        self.versionNumber = String(parts[0])
        self.buildNumber = String(parts[1])
        
        let betaVersionResults = try Process.execute(
            Bundle.main.executablePath!,
            arguments: [
                "_beta-version-number",
                url.path
            ]
        )
        
        self.betaVersion = String(decoding: betaVersionResults, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty()
    }
}

// MARK: - Use
extension XcodeApplication {
    func use() throws {
        try Process.execute(
            "/usr/bin/xcode-select",
            arguments: [
                "--switch",
                url.absoluteURL
                    .appendingPathComponent("Contents")
                    .appendingPathComponent("Developer")
                    .path
            ]
        )
        
        // Register Xcode so plugins work correctly.
        // https://nshipster.com/xcode-source-extensions/#using-pluginkit
        try Process.execute(
            "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
            arguments: [
                "-f",
                url.path
            ]
        )
    }
}

// MARK: - Comparable
extension XcodeApplication: Comparable {
    static func < (lhs: XcodeApplication, rhs: XcodeApplication) -> Bool {
        let versionResult = lhs.versionNumber.compare(rhs.versionNumber, options: .numeric)
        
        guard versionResult == .orderedSame else {
            return versionResult == .orderedAscending
        }
        
        guard let rhsBetaVersion = rhs.betaVersion else {
            return true
        }
        
        guard let lhsBetaVersion = lhs.betaVersion else {
            return false
        }
        
        return lhsBetaVersion.compare(rhsBetaVersion, options: .numeric) == .orderedAscending
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
    static func all() async throws -> [XcodeApplication] {
        let data = try Process.execute(
            "/usr/bin/mdfind",
            arguments: [
                "kMDItemCFBundleIdentifier = 'com.apple.dt.Xcode'"
            ]
        )
        
        let urls = String(decoding: data, as: UTF8.self)
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { URL(fileURLWithPath: $0, isDirectory: true) }
        
        return try await withThrowingTaskGroup(of: XcodeApplication.self) { group in
            for url in urls {
                group.addTask { try XcodeApplication(url: url) }
            }
            
            return try await group
                .reduce(into: []) { $0.append($1) }
        }
    }
}
