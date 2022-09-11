import ArgumentParser
import Foundation

struct UseCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "use",
        abstract: "Changes the version of Xcode being used"
    )
    
    @Argument(
        help: ArgumentHelp(
            "The version number to use",
            discussion: "Matches Xcode versions that start with the entered string. In the case of multiple matches, the newest matching version of Xcode is used."
        )
    )
    var version: String
    
    func run() async throws {
        let firstXcode = try await XcodeApplication
            .all()
            .sorted(by: >)
            .first { $0.versionNumber.hasPrefix(version) }
        
        guard let xcode = firstXcode else {
            throw CustomError("No version of Xcode found matching \"\(version)\"")
        }
        
        let formatter = XcodeVersionFormatter()
        let xcodeVersion = formatter.string(from: xcode)
        print("Switching to \(xcodeVersion)")
        
        try xcode.use()
    }
}
