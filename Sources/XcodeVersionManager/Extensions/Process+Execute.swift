import Foundation
import os

extension Process {
    private static let logger = Logger(
        subsystem: Bundle.main.executableURL!.lastPathComponent,
        category: "Process"
    )
    
    @discardableResult
    @objc static func execute(_ command: String, arguments: [String]) throws -> Data {
        logger.debug("\(command, privacy: .public) \(arguments.joined(separator: " "), privacy: .public)")
        
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return data
    }
}
