import Foundation

struct XcodeApplication: Encodable {
    let url: URL
    
    let versionNumber: String
    let buildNumber: String
    let betaVersion: String?
    
    init(url: URL) throws {
        let url = url.absoluteURL
        self.url = url
        
        (self.versionNumber, self.buildNumber) = try Self.versionBuild(for: url)
        self.betaVersion = try Self.betaNumber(for: url)
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
