import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Lists the installed versions of Xcode"
    )
    
    func run() throws {
        let formatter = XcodeVersionFormatter()
        
        let current = try XcodeApplication.current()
        
        try XcodeApplication
            .all()
            .sorted()
            .forEach {
                let prefix = $0 == current ? "*" : " "
                print(prefix, formatter.string(from: $0))
            }
    }
}
