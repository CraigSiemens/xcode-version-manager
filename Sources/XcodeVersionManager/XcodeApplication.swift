import Foundation
import ObjectiveC.runtime

struct XcodeApplication {
    let url: URL
    
    let versionNumber: String
    let buildNumber: String
    
    init(url: URL) throws {
        self.url = url
        
        let arguments = [
            "-c", "Print CFBundleShortVersionString",
            "-c", "Print ProductBuildVersion",
            url.absoluteURL
                .appendingPathComponent("Contents")
                .appendingPathComponent("version.plist")
                .path
        ]
        
        let results = try Process.execute("/usr/libexec/PlistBuddy", arguments: arguments)
        
        let parts = String(decoding: results, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
        
        self.versionNumber = String(parts[0])
        self.buildNumber = String(parts[1])
    }
}

// MARK: - Use
extension XcodeApplication {
    func use() throws {
        let arguments = [
            "--switch",
            url.absoluteURL
                .appendingPathComponent("Contents")
                .appendingPathComponent("Developer")
                .path
        ]

        try Process.execute("/usr/bin/xcode-select", arguments: arguments)
    }
}

// MARK: - Comparable
extension XcodeApplication: Comparable {
    static func < (lhs: XcodeApplication, rhs: XcodeApplication) -> Bool {
        let versionResult = lhs.versionNumber.compare(rhs.versionNumber, options: .numeric)
        return versionResult == .orderedAscending
            || versionResult == .orderedSame
            && lhs.buildNumber.compare(rhs.buildNumber, options: .numeric) == .orderedAscending
    }
}

// MARK: Current
extension XcodeApplication {
    static func current() throws -> XcodeApplication {
        let results = try Process.execute("/usr/bin/xcode-select", arguments: ["--print-path"])
        
        let path = String(decoding: results, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let url = URL(fileURLWithPath: path)
            .deletingLastPathComponent() // Developer
            .deletingLastPathComponent() // Contents
        
        return try XcodeApplication(url: url)
    }
}

// MARK: All
extension XcodeApplication {
    static func all() throws -> [XcodeApplication] {
        let urls = LSCopyApplicationURLsForBundleIdentifier("com.apple.dt.Xcode" as CFString, nil)?
            .takeUnretainedValue()
            as? [URL]
        
        return try (urls ?? [])
            .map { try XcodeApplication(url: $0) }
    }
}

// MARK: Beta Version
extension XcodeApplication {
    var betaVersion: String {
//        [[DVTToolsInfo toolsInfo] isBeta]
//        [[DVTToolsInfo toolsInfo] toolsBetaVersion]
        
        let dvtFoundationURL = url
            .appendingPathComponent("Contents/SharedFrameworks/DVTFoundation.framework/DVTFoundation")
        
        let frameworkHandle = dlopen(dvtFoundationURL.path, RTLD_NOW)
        
        // This has no effect, the objc runtime keeps a reference so it cante be unloaded.
        // TODO: Make a hidden subcommand that gets the beta version and exits, call it once per xcode.
        defer { dlclose(frameworkHandle) }
        
        let toolsInfoClass: AnyObject? = NSClassFromString("DVTToolsInfo")
        let toolsInfo = toolsInfoClass?.perform(NSSelectorFromString("toolsInfo")).takeUnretainedValue()
        
        print("toolsInfoClass", toolsInfoClass)
        print("toolsInfo", toolsInfo)
        
        if let isBeta = toolsInfo?.perform(NSSelectorFromString("isBeta")) {
            let isBetaValue = isBeta.takeRetainedValue()
            print(isBetaValue as? NSNumber)
        }
       
        if let toolsBetaVersion = toolsInfo?.perform(NSSelectorFromString("toolsBetaVersion")) {
            let toolsBetaVersionValue = toolsBetaVersion.takeRetainedValue()
            print(toolsBetaVersionValue as! NSNumber)
        }
        
        print("toolsInfoClass", toolsInfoClass)
        print("toolsInfo", toolsInfo)
//        print("isBeta", isBeta)
//        print("toolsBetaVersion", toolsBetaVersion)
        
        
        return "???"
    }
    
    func dumpObjcMethods(_ cls: AnyClass) {
        var methodsCount: UInt32 = 0
        let methods = class_copyMethodList(cls, &methodsCount)
        
        print("Found \(methodsCount) methods on \(cls)")

        for i in 0..<methodsCount {
            let method = methods![Int(i)]
            
            let className = String(cString: class_getName(cls))
            let selectorName = String(cString: sel_getName(method_getName(method)))
            let encodingName = String(cString: method_getTypeEncoding(method)!)

            print("\t'\(className)' has method named '\(selectorName)' of encoding '\(encodingName)'\n")
        }
        
        methods?.deallocate()
    }
}
