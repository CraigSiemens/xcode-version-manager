import ArgumentParser
import Foundation
import Cocoa

struct DownloadCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "download",
        abstract: "Open the browser to download a version of Xcode."
    )
    
    @Flag(
        name: .shortAndLong,
        help: .init("Download the matched version of Xcode without prompting for confirmation.")
    )
    var force: Bool = false
    
    @Argument(
        help: ArgumentHelp(
            "The version number to download.",
            discussion: "Matches Xcode versions that start with the entered string. In the case of multiple matches, the newest matching version of Xcode is used."
        ),
        completion: .custom { _ in
            do {
                struct EmptyResponse: Error {}
                
                let versionNumbers = try _unsafeWait {
                    let releases = try await XcodeReleases().releases
                    guard !releases.isEmpty else { throw EmptyResponse() }
                    return releases.map { $0.version.formatted(style: .option) }
                }
                
                return ["latest"] + Set(versionNumbers).sorted(by: >)
            } catch {
                return []
            }
        }
    )
    var version: String = "latest"
    
    func run() async throws {
        let releases = try await XcodeReleases()
        
        let matchingRelease: XcodeRelease?
        if version == "latest" {
            matchingRelease = releases.releases.first
        } else {
            matchingRelease = releases.releases
                .first { $0.version.formatted(style: .option).hasPrefix(version) }
        }
        
        guard let matchingRelease else {
            throw CustomError("No Xcode release found matching version '\(version)'")
        }
        
        guard force || askConfirmation(
            "Download Xcode \(matchingRelease.version.formatted())?",
            default: .yes
        ) else { return }
        
        print("Opening browser to download \(matchingRelease.version.formatted())")
        
        var downloadComponents = URLComponents(string: "https://developer.apple.com/services-account/download")!
        downloadComponents.queryItems = [
            .init(name: "path", value: matchingRelease.downloadURL.path)
        ]
        
        NSWorkspace.shared.open(downloadComponents.url!)
    }
}
