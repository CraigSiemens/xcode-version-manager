import ArgumentParser
import Foundation

@main
struct XcodeVersionManagerCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "xcvm",
        abstract: "Manage multiple installed versions of Xcode.",
        version: version,
        subcommands: [
            DownloadCommand.self,
            ListCommand.self,
            InstallCommand.self,
            UninstallCommand.self,
            UseCommand.self,
            
            // Private commands
            BetaVersionNumberCommand.self
        ],
        defaultSubcommand: ListCommand.self
    )
}
