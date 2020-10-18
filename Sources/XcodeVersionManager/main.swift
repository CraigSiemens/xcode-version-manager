import ArgumentParser
import Foundation

struct XcodeVersionManager: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "xcvm",
        abstract: "Manage multiple installed versions of Xcode",
        subcommands: [
            ListCommand.self,
            InstallCommand.self,
            UseCommand.self,
            
            // Private commands
            BetaVersionNumberCommand.self
        ],
        defaultSubcommand: ListCommand.self
    )
}

XcodeVersionManager.main()
