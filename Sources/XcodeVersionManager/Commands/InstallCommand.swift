import ArgumentParser
import Foundation

struct InstallCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Installs a version of Xcode from a downloaded xip file.",
        discussion: "Can wait for the download of a xip to complete before installing it. Expanding a xip can take a long amount of time to complete and it isn't possible to show progress."
    )
    
    @Argument(
        help: "The path to the xip or download file to install.",
        completion: CompletionKind.file(extensions: ["xip", "download"])
    )
    var fileURL: URL
    
    func run() throws {
        switch fileURL.pathExtension {
        case "download":
            try waitForDownloadCompletion(fileURL)
        default:
            try installXip(fileURL)
        }
    }
    
    private func waitForDownloadCompletion(_ url: URL) throws {
        print("Waiting for download to complete.")
        
        let queue = DispatchQueue(label: "download-watcher")
        let descriptor = open(url.path, O_EVTONLY)
        let deleteObserver = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: .delete,
            queue: queue
        )
        
        let group = DispatchGroup()
        group.enter()
        deleteObserver.setEventHandler {
            group.leave()
        }
        
        deleteObserver.resume()
        group.wait()
        
        try installXip(url.deletingPathExtension())
    }
    
    private func installXip(_ url: URL) throws {
        guard url.pathExtension == "xip" else {
            throw ValidationError("Unable to handle file with extension \"\(fileURL.pathExtension)\"")
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ValidationError("File doesn't exist at \"\(fileURL.pathExtension)\"")
        }
        
        let destinationDirectoryURL = try FileManager.default
            .url(for: .applicationDirectory,
                 in: .localDomainMask,
                 appropriateFor: nil,
                 create: false)
        
        let tempFolder = try FileManager.default
            .url(for: .itemReplacementDirectory,
                 in: .userDomainMask,
                 appropriateFor: destinationDirectoryURL,
                 create: true)
        
        FileManager.default.changeCurrentDirectoryPath(tempFolder.path)
        
        print("Expanding \(url.lastPathComponent), this will definitely take a while.")
        
        try Process.execute("/usr/bin/xip", arguments: [
            "--expand",
            url.path,
        ])
        
        // Useful for testing so you don't have to wait for the xip to expand. Comment out the above line.
//        try FileManager.default
//            .createDirectory(at: tempFolder.appendingPathComponent("Xcode.app"),
//                             withIntermediateDirectories: false,
//                             attributes: nil)
        
        let contents = try FileManager.default
            .contentsOfDirectory(at: tempFolder,
                                 includingPropertiesForKeys: nil,
                                 options: .skipsSubdirectoryDescendants)
        
        guard let expandedApplication = contents.first(where: { $0.lastPathComponent.contains("Xcode") }) else {
            throw CustomError("Could not find an Xcode application after expanding the xip.")
        }
        
        print("Verifying")
        
        let xcodeApplication = try XcodeApplication(url: expandedApplication)
        let xcodeFileName = XcodeFileNameFormatter().string(from: xcodeApplication)
                
        let destinationURL = destinationDirectoryURL
            .appendingPathComponent(xcodeFileName)
            .appendingPathExtension(expandedApplication.pathExtension)
        
        print("Moving Xcode to \(destinationURL.path) \(Date())")
        
        try FileManager.default
            .moveItem(at: expandedApplication,
                      to: destinationURL)
    }
}

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        self.init(fileURLWithPath: argument, relativeTo: currentDirectory)
    }
}
