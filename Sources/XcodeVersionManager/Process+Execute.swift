import Foundation

extension Process {
    @discardableResult
    @objc static func execute(_ command: String, arguments: [String]) throws -> Data {
        #if DEBUG
        print(([command] + arguments).joined(separator: " "))
        #endif
        
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
