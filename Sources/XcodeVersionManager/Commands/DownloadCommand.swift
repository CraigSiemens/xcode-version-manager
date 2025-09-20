import ArgumentParser
import Foundation
import Cocoa

struct DownloadCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
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
        completion: .custom { _, _, _ in
            do {
                let releases = try await XcodeReleases().releases
                let versionNumbers = releases.map { $0.version.formatted(style: .option) }
                let versions = ["latest"] + versionNumbers
                return versions
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
        
        let xcodeName = "Xcode \(matchingRelease.version.formatted())"
        guard force || askConfirmation(
            "Download \(xcodeName)?",
            default: .yes
        ) else { return }
        
        print("Opening browser to download \(xcodeName)")
        
        var downloadComponents = URLComponents(string: "https://developer.apple.com/services-account/download")!
        downloadComponents.queryItems = [
            .init(name: "path", value: matchingRelease.downloadURL.path)
        ]
        
        NSWorkspace.shared.open(downloadComponents.url!)
    }
}
