import ArgumentParser
import Foundation

struct UseCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "use",
        abstract: "Changes the version of Xcode being used"
    )
    
    @Argument(help: "The version number to use")
    var version: String
    
    func run() throws {
        let firstXcode: XcodeApplication? = try XcodeApplication
            .all()
            .sorted(by: >)
            .first { $0.versionNumber.hasPrefix(version) }
        
        guard let xcode = firstXcode else {
            throw CustomError(localizedDescription: "No version of Xcode found matching \"\(version)\"")
        }
        
        let formatter = XcodeVersionFormatter()
        let xcodeVersion = formatter.string(from: xcode)
        print("Switching to \(xcodeVersion)")
        print(xcode.url.path)

        try xcode.use()
    }
}
