import Foundation

extension Process {
    @discardableResult
    @objc static func execute(_ command: String, arguments: [String]) throws -> Data {
        #if DEBUG
        print(([command] + arguments).joined(separator: " "))
        #endif
        
        let task = Process()
        task.launchPath = command
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe

        try task.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return data
    }
}
