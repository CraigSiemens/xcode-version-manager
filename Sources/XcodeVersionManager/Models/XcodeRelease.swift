import Foundation

struct XcodeRelease {
    let download: Download
    let version: Version
    let requires: OperatingSystemVersion
    let date: CalendarDate
    
    struct Download: Equatable {
        let architectures: [Architecture]
        let url: URL
    }
    
    struct Version: Equatable {
        let number: String
        let build: String
        let release: Release
        
        enum Release: Codable, Equatable {
            case beta(Int)
            case rc(Int)
            case release
        }
    }
}

extension XcodeRelease: Equatable {
    static func == (lhs: XcodeRelease, rhs: XcodeRelease) -> Bool {
        lhs.version == rhs.version
    }
}

extension XcodeRelease: Comparable {
    static func < (lhs: XcodeRelease, rhs: XcodeRelease) -> Bool {
        lhs.date < rhs.date
    }
}
