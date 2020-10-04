import ArgumentParser
import Foundation

struct XcodeVersionManager: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Manage multiple installed version of Xcode",
        subcommands: [
            ListCommand.self
        ],
        defaultSubcommand: ListCommand.self
    )
}

XcodeVersionManager.main()
