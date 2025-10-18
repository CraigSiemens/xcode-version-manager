import Foundation

public struct StandardErrorOutputStream: TextOutputStream {
    public init() {}
    
    public func write(_ string: String) {
        let data = Data(string.utf8)
        try? FileHandle.standardError.write(contentsOf: data)
    }
}
