import ArgumentParser
import Foundation

struct UninstallCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Uninstalls a version of Xcode"
    )
    
    @Argument(
        help: ArgumentHelp(
            "The version number of Xcode to uninstall",
            discussion: "Matches Xcode versions that start with the entered string. In the case of multiple matches, the oldest matching version of Xcode is used."
        )
    )
    var version: String
    
    func run() throws {
        let firstXcode: XcodeApplication? = try XcodeApplication
            .all()
            .sorted(by: <)
            .first { $0.versionNumber.hasPrefix(version) }
        
        guard let xcode = firstXcode else {
            throw CustomError("No version of Xcode found matching \"\(version)\"")
        }
        
        print("Are you sure you want to uninstall \(xcode.url.lastPathComponent)? [y/N]")
        guard readLine(strippingNewline: true)?.lowercased() == "y" else {
            return
        }
        
        try FileManager.default.removeItem(at: xcode.url)
    }
}
