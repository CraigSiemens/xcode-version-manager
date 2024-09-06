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
    
    @OptionGroup var xcodeVersion: InstalledXcodeVersion
    
    func run() async throws {
        let xcode = try await xcodeVersion.xcodeApplication()
        
        guard force || askConfirmation(
            "Are you sure you want to uninstall \(xcode.url.lastPathComponent)?",
            default: .no
        ) else { return }
        
        print("Uninstalling \(xcode.url.lastPathComponent)...")
        try FileManager.default.removeItem(at: xcode.url)
    }
}
