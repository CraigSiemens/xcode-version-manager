import ArgumentParser

struct InstalledXcodeVersion: ParsableArguments {
    @Flag(
        help: .init("Controls how the passed version is matched to an install of Xcode.")
    )
    var versionMatch: VersionMatch = .exact
    
    @Argument(
        help: ArgumentHelp(
            "The version number of Xcode to uninstall."
        ),
        completion: .custom { _, _, _ in
            do {
                var formatter = XcodeVersionFormatter()
                formatter.separator = "-"
                
                return try await XcodeApplication
                    .all()
                    .map(formatter.string)
            } catch {
                return []
            }
        }
    )
    var version: String
    
    func xcodeApplication() async throws -> XcodeApplication {
        var formatter = XcodeVersionFormatter()
        formatter.separator = "-"
        
        let xcode = try await XcodeApplication
            .all()
            .sorted(by: versionMatch.order)
            .first {
                let formattedVersion = formatter.string(from: $0)
                if versionMatch.isPrefix {
                    return formattedVersion.hasPrefix(version)
                } else {
                    return formatter.string(from: $0) == version
                }
            }
        
        guard let xcode else {
            throw CustomError("No version of Xcode found matching \"\(version)\"")
        }
        
        return xcode
    }
}

// MARK: - VersionMatch
extension InstalledXcodeVersion {
    enum VersionMatch: EnumerableFlag {
        case exact
        case oldestWithPrefix
        case newestWithPrefix
        
        var isPrefix: Bool {
            switch self {
            case .exact:
                false
            case .oldestWithPrefix, .newestWithPrefix:
                true
            }
        }
        
        func order(lhs: XcodeApplication, rhs: XcodeApplication) throws -> Bool {
            switch self {
            case .exact, .oldestWithPrefix:
                lhs < rhs
            case .newestWithPrefix:
                lhs > rhs
            }
        }
    }
}
