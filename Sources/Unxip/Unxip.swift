import libunxip
import Foundation

public struct XIPFile {
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func expand() async throws {
        let handle = try FileHandle(forReadingFrom: url)
        let data = DataReader(descriptor: handle.fileDescriptor)
        
        for try await _ in Unxip.makeStream(from: .xip(input: data), to: .disk, input: data) {}
    }
}
