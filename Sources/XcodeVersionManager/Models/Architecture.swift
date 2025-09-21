import Darwin

enum Architecture: String {
    case arm64
    case x86_64
    
    static var current: Self? {
        var name: utsname = .init()
        uname(&name)
        
        let machine = withUnsafePointer(to: name.machine) { pointer in
            pointer.withMemoryRebound(
                to: UInt8.self,
                capacity: MemoryLayout.size(ofValue: name.machine)
            ) { pointer in
                String(cString: pointer)
            }
        }
        
        return .init(rawValue: machine)
    }
}
