import ArgumentParser
import Foundation

struct UninstallCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Uninstalls a version of Xcode."
    )
    
    @Argument(
        help: ArgumentHelp(
            "The version number of Xcode to uninstall.",
            discussion: "Matches Xcode versions that start with the entered string. In the case of multiple matches, the oldest matching version of Xcode is used."
        )
    )
    var version: String
    
    func run() async throws {
        let firstXcode = try await XcodeApplication
            .all()
            .sorted(by: <)
            .first { $0.versionNumber.hasPrefix(version) }
        
        guard let xcode = firstXcode else {
            throw CustomError("No version of Xcode found matching \"\(version)\"")
        }
        
        guard askConfirmation("Are you sure you want to uninstall \(xcode.url.lastPathComponent)?") else {
            return
        }
        
        try FileManager.default.removeItem(at: xcode.url)
    }
}
