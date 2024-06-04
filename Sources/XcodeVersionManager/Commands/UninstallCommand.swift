import ArgumentParser
import Foundation

struct UninstallCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Uninstalls a version of Xcode."
    )
    
    @Flag(
        name: .shortAndLong,
        help: .init("Uninstall the matched version of Xcode without prompting for confirmation.")
    )
    var force: Bool = false
    
    @Flag(
        help: .init("Controls how the passed version is matches to an install of Xcode.")
    )
    var versionMatch: VersionMatch = .exact
    
    @Argument(
        help: ArgumentHelp(
            "The version number of Xcode to uninstall."
        ),
        completion: .custom { words in
            do {
                return try _unsafeWait {
                    var formatter = XcodeVersionFormatter()
                    formatter.separator = "-"
                    
                    return try await XcodeApplication
                        .all()
                        .map(formatter.string)
                }
            } catch {
                return []
            }
        }
    )
    var version: String
    
    func run() async throws {
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
        
        guard force || askConfirmation(
            "Are you sure you want to uninstall \(xcode.url.lastPathComponent)?"
        ) else {
            return
        }
        
        try FileManager.default.removeItem(at: xcode.url)
    }
}

extension UninstallCommand {
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
