//
//  File.swift
//  
//
//  Created by Craig on 2023-10-30.
//

import Foundation

class XcodeReleases {
    private static let cacheURL = FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("xcvm")
        .appendingPathComponent("releases.json")
    
    var releases: [XcodeRelease] = []
    
    func loadCached() throws {
        guard releases.isEmpty else { return }
        
        let data = try Data(contentsOf: Self.cacheURL)
        releases = try JSONDecoder().decode([XcodeRelease].self, from: data)
    }
    
    func loadRemote() async throws {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "https://xcodereleases.com/data.json")!)
        
        releases = try JSONDecoder()
            .decode([XcodeReleaseResponse].self, from: data)
            .prefix(100)
            .compactMap(XcodeRelease.init(response:))
        
        try JSONEncoder()
            .encode(releases)
            .write(to: Self.cacheURL)
    }
}

struct XcodeRelease: Codable, Equatable {
    let downloadURL: URL
    let version: Version
    
    fileprivate init?(response: XcodeReleaseResponse) {
        guard let downloadURL = response.links?.download?.url,
              let version = Version(response: response.version)
        else { return nil }
        
        self.downloadURL = downloadURL
        self.version = version
    }
    
    struct Version: Codable, Equatable {
        let number: String
        let build: String
        let release: Release
        
        fileprivate init?(response: XcodeReleaseResponse.Version) {
            guard let release = Release(response: response.release) else { return nil }
            
            self.number = response.number
            self.build = response.build
            self.release = release
        }
        
        enum Release: Codable, Equatable {
            case beta(Int)
            case rc(Int)
            case release
            
            fileprivate init?(response: XcodeReleaseResponse.Version.Release) {
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
    }
}

private struct XcodeReleaseResponse: Decodable {
    let links: Links?
    let version: Version
    
    struct Links: Decodable {
        let download: Download?
        
        struct Download: Decodable {
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
