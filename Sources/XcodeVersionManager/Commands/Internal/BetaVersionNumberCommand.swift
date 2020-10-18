import ArgumentParser
import Foundation

struct BetaVersionNumberCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "beta-version-number",
        abstract: "Internal command to get the beta version number from an Xcode app.",
        shouldDisplay: false)
    
    @Argument(help: "The path to the Xcode app")
    var xcodeURL: URL
    
    func run() throws {
        let dvtFoundationURL = xcodeURL
            .appendingPathComponent("Contents/SharedFrameworks/DVTFoundation.framework/DVTFoundation")
        
        let frameworkHandle = dlopen(dvtFoundationURL.path, RTLD_NOW)
        defer { dlclose(frameworkHandle) }
        
        guard let toolsInfoClass: AnyObject = NSClassFromString("DVTToolsInfo") else {
            return
        }
        
        let toolsInfo = toolsInfoClass.perform(NSSelectorFromString("toolsInfo")).takeRetainedValue()
        
        guard toolsInfo.isBeta() else {
            return
        }
        
        print(toolsInfo.toolsBetaVersion())
    }
}

@objc
protocol DVTToolsInfoPrivate {
    func isBeta() -> Bool
    func toolsBetaVersion() -> Int
}
