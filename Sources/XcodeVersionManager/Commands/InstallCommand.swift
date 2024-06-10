import ArgumentParser
import Foundation
import Unxip
import os

struct InstallCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Installs a version of Xcode from a downloaded xip file.",
        discussion: "Can wait for the download of a xip to complete before installing it. Expanding a xip can take a long amount of time to complete and it isn't possible to show progress."
    )
    
    private static let logger = Logger(
        subsystem: Bundle.main.executableURL!.lastPathComponent,
        category: "install"
    )
    
    private static let signposter = OSSignposter(logger: logger)
    
    @Argument(
        help: .init(
            "The path to the xip or download file to install.",
            discussion: "Browsers created a file when the download is in progress. Safari uses the extension .download and Chrome uses .crdownload. When passed a download file, it will wait for the download to complete before installing Xcode."
        ),
        completion: CompletionKind.file(extensions: ["xip", "download", "crdownload"])
    )
    var fileURL: URL
    
    @Flag(
        help: .init(
            "Expand the xip file using the system xip command.",
            discussion: """
            By default `unxip` is used for expanding the file, which is a faster,  open source implementation of expanding xip files. If `unxip` fails to expand the file, enabling this option will use the system `xip` command for expanding the xip file.
            Source: https://github.com/saagarjha/unxip
            """
        )
    )
    var useXip = false
    
    @Flag(
        help: .init("The install location for Xcode.")
    )
    var installLocation: InstallLocation = .applications
    
    func run() async throws {
        let destinationDirectoryURL = try FileManager.default
            .url(
                for: .applicationDirectory,
                in: installLocation.domainMask,
                appropriateFor: nil,
                create: false
            )
        
        var fileURL = fileURL
        
        if fileURL.pathExtension.hasSuffix("download") {
            fileURL = try await waitForDownloadCompletion(fileURL)
        }
        
        fileURL = try await expandXip(fileURL, for: destinationDirectoryURL)
        
        try await installXcode(fileURL, to: destinationDirectoryURL)
    }
    
    private func waitForDownloadCompletion(_ url: URL) async throws -> URL {
        guard url.pathExtension == "download" else {
            return url
        }
        
        try guardFileExists(url: url)
        
        print("Waiting for download to complete...")
        
        let queue = DispatchQueue(label: "download-watcher")
        let descriptor = open(url.path, O_EVTONLY)
        let deleteObserver = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: .delete,
            queue: queue
        )
        
        await withCheckedContinuation { continuation in
            deleteObserver.setEventHandler {
                continuation.resume()
            }
            deleteObserver.resume()
        }
        
        return url.deletingPathExtension()
    }
    
    private func expandXip(_ url: URL, for destination: URL) async throws -> URL {
        let unxipState = Self.signposter.beginInterval("expand")
        defer { Self.signposter.endInterval("expand", unxipState) }
        
        guard url.pathExtension == "xip" else {
            throw ValidationError("Unable to handle file with extension \"\(fileURL.pathExtension)\"")
        }
        
        try guardFileExists(url: url)
        
        let tempFolder = try FileManager.default
            .url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: destination,
                create: true
            )
        
        Self.logger.debug("Temp Location: \(tempFolder.path, privacy: .public)")
        
        print("Expanding \(url.lastPathComponent)... (this will take a while)")
        FileManager.default.changeCurrentDirectoryPath(tempFolder.path)
            
        if !useXip {
            try await XIPFile(url: url).expand()
        } else {
            try Process.execute(
                "/usr/bin/xip",
                arguments: [
                    "--expand",
                    url.path,
                ]
            )
        }
        
        let expandedApplication = try FileManager.default
            .contentsOfDirectory(
                at: tempFolder,
                includingPropertiesForKeys: nil,
                options: .skipsSubdirectoryDescendants
            )
            .first { $0.lastPathComponent.contains("Xcode") }
        
        guard let expandedApplication else {
            throw CustomError("Could not find an Xcode application after expanding the xip.")
        }
        
        return expandedApplication
    }
    
    private func installXcode(_ url: URL, to destination: URL) async throws {
        let verifyingState = Self.signposter.beginInterval("verifying")
        defer { Self.signposter.endInterval("verifying", verifyingState) }
        
        print("Verifying...")
        
        let xcodeApplication = try XcodeApplication(url: url)
        let xcodeFileName = XcodeFileNameFormatter().string(from: xcodeApplication)
        
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        
        let destinationURL = destination
            .appendingPathComponent(xcodeFileName)
            .appendingPathExtension(url.pathExtension)
        
        print("Moving Xcode to \(destinationURL.path)...")
        
        try FileManager.default
            .moveItem(
                at: url,
                to: destinationURL
            )
    }
    
    private func guardFileExists(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ValidationError("File doesn't exist at \"\(url.path)\"")
        }
    }
}

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        self.init(fileURLWithPath: argument, relativeTo: currentDirectory)
    }
}

extension InstallCommand {
    enum InstallLocation: EnumerableFlag {
        case applications
        case userApplications
        
        var domainMask: FileManager.SearchPathDomainMask {
            switch self {
            case .applications:
                return .localDomainMask
            case .userApplications:
                return .userDomainMask
            }
        }
    }
}
