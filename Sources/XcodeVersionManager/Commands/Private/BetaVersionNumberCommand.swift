import ArgumentParser
import Foundation

struct BetaVersionNumberCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "_beta-version-number",
        abstract: "Internal command to get the beta version number from an Xcode app.",
        shouldDisplay: false
    )
    
    @Argument(help: "The path to the Xcode app")
    var xcodeURL: URLArgument
    
    func run() throws {
        let dvtFoundationURL = xcodeURL
            .url
            .appendingPathComponent("Contents/SharedFrameworks/DVTFoundation.framework/DVTFoundation")
        
        guard FileManager.default.fileExists(atPath: dvtFoundationURL.path) else {
            return
        }
        
        let frameworkHandle = dlopen(dvtFoundationURL.path, RTLD_NOW)
        defer { dlclose(frameworkHandle) }
        
        let toolsInfoSelector = NSSelectorFromString("toolsInfo")
        
        guard let toolsInfoClass: AnyObject = NSClassFromString("DVTToolsInfo"),
              toolsInfoClass.responds(to: toolsInfoSelector)
        else { return }
        
        let toolsInfo = toolsInfoClass.perform(toolsInfoSelector).takeRetainedValue()
        
        guard toolsInfo.responds(to: NSSelectorFromString("isBeta")),
            toolsInfo.isBeta()
        else { return }
        
        print(toolsInfo.toolsBetaVersion())
    }
}

/// Xcode 16.2 and earlier
@objc
protocol DVTToolsInfoPrivate {
    func isBeta() -> Bool
    func toolsBetaVersion() -> Int
}
