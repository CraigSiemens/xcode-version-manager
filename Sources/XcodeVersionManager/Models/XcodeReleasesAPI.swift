import Foundation

enum XcodeReleasesAPI {
    static func releases() async throws -> [XcodeRelease] {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "https://xcodereleases.com/data.json")!)
        
        return try JSONDecoder()
            .decode([Responses.XcodeRelease].self, from: data)
            .compactMap(XcodeRelease.init(response:))
    }
}

// MARK: - Responses

private extension XcodeReleasesAPI {
    enum Responses {}
}

extension XcodeReleasesAPI.Responses {
    struct XcodeRelease: Decodable {
        let links: Links?
        let version: Version
        let requires: String
        let date: CalendarDate
        
        struct Links: Decodable {
            let download: Download?
            
            struct Download: Decodable {
                let architectures: [String]?
                let url: URL
            }
        }
        
        struct Version: Decodable {
            let number: String
            let build: String
            let release: Release
            
            struct Release: Decodable {
                let beta: Int?
                let rc: Int?
                let release: Bool?
            }
        }
    }
}

// MARK: - Inits

private extension XcodeRelease {
    init?(response: XcodeReleasesAPI.Responses.XcodeRelease) {
        guard let responseDownload = response.links?.download,
              let version = Version(response: response.version)
        else { return nil }
        
        let download = Download(
            architectures: responseDownload.architectures?.compactMap(Architecture.init) ?? [],
            url: responseDownload.url
        )
        
        let requiresParts = response.requires.components(separatedBy: ".").compactMap(Int.init)
        var requires = OperatingSystemVersion()
        if requiresParts.count > 0 { requires.majorVersion = requiresParts[0] }
        if requiresParts.count > 1 { requires.minorVersion = requiresParts[1] }
        if requiresParts.count > 2 { requires.patchVersion = requiresParts[2] }
        
        self.init(
            download: download,
            version: version,
            requires: requires,
            date: response.date
        )
    }
}

private extension XcodeRelease.Version {
    init?(response: XcodeReleasesAPI.Responses.XcodeRelease.Version) {
        guard let release = Release(response: response.release) else { return nil }
        
        self.number = response.number
        self.build = response.build
        self.release = release
    }
}

private extension XcodeRelease.Version.Release {
    init?(response: XcodeReleasesAPI.Responses.XcodeRelease.Version.Release) {
        if let beta = response.beta {
            self = .beta(beta)
        } else if let rc = response.rc {
            self = .rc(rc)
        } else if response.release == true {
            self = .release
        } else {
            return nil
        }
    }
}
