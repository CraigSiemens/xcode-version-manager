import ArgumentParser
import Foundation

struct UseCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "use",
        abstract: "Changes the version of Xcode being used.",
        discussion: """
            Internally this calls xcode-select which requires superuser permissions (see `man xcode-select`). Calling this command will depend on your specific setup and comfort level granting superuser permissions.
        """
    )
    
    @Flag(help: "How to provide superuser permissions to xcode-select.")
    var xcodeSelectPermissions: XcodeApplication.XcodeSelectPermissions = .inherit
    
    @OptionGroup var xcodeVersion: InstalledXcodeVersion
    
    func run() async throws {
        let xcode = try await xcodeVersion.xcodeApplication()
        
        let formatter = XcodeVersionFormatter()
        let xcodeVersion = formatter.string(from: xcode)
        print("Switching to \(xcodeVersion)")
        
        try xcode.use(permissions: xcodeSelectPermissions)
    }
}

extension XcodeApplication.XcodeSelectPermissions: EnumerableFlag {
    static var allCases: [Self] {
        [.inherit, .sudoAskpass]
    }
    
    static func help(for value: Self) -> ArgumentHelp? {
        switch value {
        case .inherit:
            ArgumentHelp(
                "xcode-select will be run with same permissions xcvm has.",
                discussion: #"Calling "sudo xcvm ..." may be required if you do not already have superuser permissions."#
            )
            
        case .sudoAskpass:
            ArgumentHelp(
                #"xcvm will call xcode-select with "sudo --askpass ..."."#,
                discussion: """
                The behaviour will be based on the system config.
                  1. If xcode-select has been added to sudoers with NOPASSWD, it won't need to prompt the user.
                  2. If sudo has been configured to allow Touch ID, a prompt will be shown. See /etc/pam.d/sudo_local.template.
                  3. If sudo requires a password, it will call the helper program specified by the SUDO_ASKPASS environment variable.
                See `man sudo` for more details.
                """
            )
        }
    }
}
