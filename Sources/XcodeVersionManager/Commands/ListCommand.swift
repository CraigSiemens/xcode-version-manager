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
            .sorted(by: <)
            .forEach {
                let prefix = $0 == current ? "*" : " "
                let formattedVersion = formatter.string(from: $0)
                    .padding(toLength: 15, withPad: " ", startingAt: 0)
                let name = $0.url.deletingPathExtension().lastPathComponent
                
                print(prefix, formattedVersion, name)
            }
    }
}
