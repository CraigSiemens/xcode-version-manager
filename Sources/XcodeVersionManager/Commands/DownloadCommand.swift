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
        help: .init("Prefer downloading a Universal version, if available.")
    )
    var preferUniversal: Bool = false
    
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
                let releases = try await XcodeReleasesAPI.releases()
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
        let currentArchitecture = Architecture.current
        
        let releases = try await XcodeReleasesAPI.releases()
            .filter { release in
                guard let currentArchitecture else { return true }
                
                return release.download.architectures.isEmpty
                || release.download.architectures.contains(currentArchitecture)
            }
            .sorted { lhs, rhs in
                if preferUniversal {
                    lhs.download.isUniversal && !rhs.download.isUniversal
                } else {
                    !lhs.download.isUniversal && rhs.download.isUniversal
                }
            }
        
        let matchingRelease: XcodeRelease?
        if version == "latest" {
            matchingRelease = releases.first
        } else {
            matchingRelease = releases
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
            .init(name: "path", value: matchingRelease.download.url.path)
        ]
        
        NSWorkspace.shared.open(downloadComponents.url!)
    }
}
