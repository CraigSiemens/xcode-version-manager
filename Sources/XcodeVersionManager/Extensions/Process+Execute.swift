import Foundation
import os

extension Process {
    private struct FailureError: LocalizedError {
        let status: Int32
        let standardError: String?
        
        var errorDescription: String? {
            if let standardError, !standardError.isEmpty {
                return standardError
            }
            
            return "Process exited with status \(status)"
        }
    }
    
    private static let logger = Logger(
        subsystem: Bundle.main.executableURL!.lastPathComponent,
        category: "process"
    )
    
    @discardableResult
    static func execute(_ command: String, arguments: [String]) throws -> Data {
        logger.debug("\(command, privacy: .public) \(arguments.joined(separator: " "), privacy: .public)")
        
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        
        let standardOutput = Pipe()
        process.standardOutput = standardOutput
        
        let standardError = Pipe()
        process.standardError = standardError
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            let errorData = standardError.fileHandleForReading.readDataToEndOfFile()
                        
            throw FailureError(
                status: process.terminationStatus,
                standardError: String(data: errorData, encoding: .utf8)
            )
        }
        
        return standardOutput.fileHandleForReading.readDataToEndOfFile()
    }
}
