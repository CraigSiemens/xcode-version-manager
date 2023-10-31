import ArgumentParser
import Foundation
import Cocoa

struct DownloadCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "download",
        abstract: "Changes the version of Xcode being used."
    )
    
    @Argument(
        help: ArgumentHelp(
            "The version number to download.",
            discussion: "Matches Xcode versions that start with the entered string. In the case of multiple matches, the newest matching version of Xcode is used."
        ),
        completion: .custom { _ in
            let releases = XcodeReleases()
            do {
                try releases.loadCached()
                let numbers = Set(releases.releases.map(\.version.number))
                return ["latest"] + numbers.sorted(by: >)
            } catch {
                return []
            }
        }
    )
    var version: String = "latest"
    
    func run() async throws {
        let releases = XcodeReleases()
        try await releases.loadRemote()
        
        let matchingRelease: XcodeRelease?
        if version == "latest" {
            matchingRelease = releases.releases.first
        } else {
            matchingRelease = releases.releases.first { $0.version.number.hasPrefix(version) }
        }
        
        guard let matchingRelease else {
            throw CustomError("No Xcode release found matching version '\(version)'")
        }
        
        var downloadComponents = URLComponents(string: "https://developer.apple.com/services-account/download")!
        downloadComponents.queryItems = [
            .init(name: "path", value: matchingRelease.downloadURL.path)
        ]
        
        NSWorkspace.shared.open(downloadComponents.url!)
    }
}
