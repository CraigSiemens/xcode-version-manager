import ArgumentParser
import Foundation

struct URLArgument: ExpressibleByArgument {
    let url: URL
    
    public init?(argument: String) {
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        self.url = .init(fileURLWithPath: argument, relativeTo: currentDirectory)
    }
}
