import ArgumentParser
import Foundation

struct UninstallCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Uninstalls a version of Xcode."
    )
    
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
            .sorted(by: <)
            .first {
                formatter.string(from: $0) == version
            }
        
        guard let xcode else {
            throw CustomError("No version of Xcode found matching \"\(version)\"")
        }
        
        guard askConfirmation("Are you sure you want to uninstall \(xcode.url.lastPathComponent)?") else {
            return
        }
        
        try FileManager.default.removeItem(at: xcode.url)
    }
}
