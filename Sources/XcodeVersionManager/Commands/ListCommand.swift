import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Lists the installed versions of Xcode"
    )
    
    func run() throws {
        let formatter = XcodeVersionFormatter()
        try XcodeApplication
            .all()
            .sorted()
            .forEach {
                print(formatter.string(from: $0))
            }
    }
}
