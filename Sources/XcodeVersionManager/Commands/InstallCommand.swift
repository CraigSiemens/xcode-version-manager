import ArgumentParser
import Foundation

struct InstallCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Installs a Xcode from a downloaded xip file.",
        discussion: "Expanding a xip can take a long amount of time to complete and it isn't possible to show progress."
    )
    
    @Argument(help: "The path to the xip file to install",
              completion: CompletionKind.file(extensions: ["xip"]))
    var xipURL: URL
    
    func run() throws {
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
        
        print("Expanding \(xipURL.lastPathComponent), this could take a while.")
        
        try Process.execute("/usr/bin/xip", arguments: [
            "--expand",
            xipURL.path,
        ])
        
//        try FileManager.default
//            .createDirectory(at: tempFolder.appendingPathComponent("Xcode.app"),
//                             withIntermediateDirectories: false,
//                             attributes: nil)
        
        let contents = try FileManager.default
            .contentsOfDirectory(at: tempFolder,
                                 includingPropertiesForKeys: nil,
                                 options: .skipsSubdirectoryDescendants)
        
        guard let expandedApplication = contents.first(where: { $0.lastPathComponent.contains("Xcode") }) else {
            throw CustomError(localizedDescription: "Could not find an Xcode application after expanding the xip.")
        }
        
        let xcodeFileName = xipURL
            .deletingPathExtension()
            .lastPathComponent
            .map { CharacterSet.alphanumerics.contains($0) ? String($0) : "-" }
            .joined()
        
        let destinationURL = destinationDirectoryURL
            .appendingPathComponent(xcodeFileName)
            .appendingPathExtension(expandedApplication.pathExtension)
        
        print("Moving Xcode to \(destinationURL.path)")
        
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
