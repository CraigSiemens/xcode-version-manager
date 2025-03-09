import Foundation

// MARK: - Version and Build
extension XcodeApplication {
    static func versionBuild(for url: URL) throws -> (versionNumber: String, buildNumber: String) {
        let versionPlist = try Self.plist(
            from: url
                .appendingPathComponent("Contents")
                .appendingPathComponent("version.plist")
        )
        
        guard let versionNumber = versionPlist["CFBundleShortVersionString"] as? String else {
            throw VersionParsingError("Unable to parse version number")
        }
        
        guard let buildNumber = versionPlist["ProductBuildVersion"] as? String else {
            throw VersionParsingError("Unable to parse build number")
        }
        
        return (versionNumber, buildNumber)
    }
}

// MARK: - Beta
extension XcodeApplication {
    static func betaNumber(for url: URL) throws -> String? {
        guard try isBeta(for: url) else { return nil }
        
        return try betaNumberFromPlist(for: url)
        ?? betaNumberFromProcess(for: url)
    }
    
    private static func isBeta(for url: URL) throws -> Bool {
        let licenseInfoPlist = try Self.plist(
            from: url
                .appendingPathComponent("Contents")
                .appendingPathComponent("Resources")
                .appendingPathComponent("LicenseInfo.plist")
        )
        
        guard let licenseType = licenseInfoPlist["licenseType"] as? String
        else { return false }
        
        return licenseType == "Beta"
    }
    
    private static func betaNumberFromPlist(for url: URL) throws -> String? {
        let plistURL = url
            .appendingPathComponent("Contents")
            .appendingPathComponent("Resources")
            .appendingPathComponent("BetaVersion.plist")
        
        guard FileManager.default.fileExists(atPath: plistURL.path) else {
            return nil
        }
        
        let betaVersionPlist = try Self.plist(from: plistURL)
        
        return betaVersionPlist["seedNumber"] as? String
    }
    
    private static func betaNumberFromProcess(for url: URL) throws -> String? {
        let betaVersionResults = try Process.execute(
            Bundle.main.executablePath!,
            arguments: [
                "_beta-version-number",
                url.path
            ]
        )
        
        return String(decoding: betaVersionResults, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty()
    }
}

// MARK: - Utility
private extension XcodeApplication {
    struct VersionParsingError: LocalizedError {
        var errorDescription: String?
        
        init(_ errorDescription: String?) {
            self.errorDescription = errorDescription
        }
    }
    
    static func plist(from url: URL) throws -> [String: Any] {
        let plistData = try Data(contentsOf: url)
        
        let plist = try PropertyListSerialization.propertyList(
            from: plistData,
            format: nil
        )
        
        guard let plist = plist as? [String: Any] else {
            throw VersionParsingError("Unable to parse \(url.lastPathComponent)")
        }
        
        return plist
    }
}
