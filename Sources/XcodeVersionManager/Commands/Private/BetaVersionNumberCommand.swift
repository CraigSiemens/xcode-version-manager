import ArgumentParser
import Foundation

struct BetaVersionNumberCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "_beta-version-number",
        abstract: "Internal command to get the beta version number from an Xcode app.",
        shouldDisplay: false
    )
    
    @Argument(help: "The path to the Xcode app")
    var xcodeURL: URL
    
    func run() throws {
        let dvtFoundationURL = xcodeURL
            .appendingPathComponent("Contents/SharedFrameworks/DVTFoundation.framework/DVTFoundation")
        
        guard FileManager.default.fileExists(atPath: dvtFoundationURL.path) else {
            return
        }
        
        let frameworkHandle = dlopen(dvtFoundationURL.path, RTLD_NOW)
        defer { dlclose(frameworkHandle) }
        
        guard let toolsInfoClass: AnyObject = NSClassFromString("DVTToolsInfo") else {
            return
        }
        
        let toolsInfo = toolsInfoClass.perform(NSSelectorFromString("toolsInfo")).takeRetainedValue()
        
        if toolsInfo.isBeta() {
            print(toolsInfo.toolsBetaVersion())
        }
    }
}

@objc
protocol DVTToolsInfoPrivate {
    func isBeta() -> Bool
    func toolsBetaVersion() -> Int
}
