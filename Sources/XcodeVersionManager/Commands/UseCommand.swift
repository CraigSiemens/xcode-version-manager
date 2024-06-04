import ArgumentParser
import Foundation

struct UseCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "use",
        abstract: "Changes the version of Xcode being used.",
        discussion: """
            Internally this calls xcode-select which requires superuser permissions (see `man xcode-select`). Calling this command will depend on your specific setup and comfort level granting superuser permissions.
        """
    )
    
    @Flag(help: "How to provide superuser permissions to xcode-select.")
    var xcodeSelectPermissions: XcodeApplication.XcodeSelectPermissions = .inherit
    
    @Argument(
        help: ArgumentHelp(
            "The version number to use.",
            discussion: "Matches Xcode versions that start with the entered string. In the case of multiple matches, the newest matching version of Xcode is used."
        )
    )
    var version: String
    
    func run() async throws {
        let xcode = try await XcodeApplication
            .all()
            .sorted(by: >)
            .first { $0.versionNumber.hasPrefix(version) }
        
        guard let xcode else {
            throw CustomError("No version of Xcode found matching \"\(version)\"")
        }
        
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
            #"xcode-select will be run with same permissions xcvm has. Calling "sudo xcvm ..." may be required if you do not already have superuser permissions."#
            
        case .sudoAskpass:
                #"""
                xcvm will call xcode-select with "sudo --askpass ...". The behaviour will be based on the system config.
                  1. If xcode-select has been added to sudoers with NOPASSWD, it won't need to prompt the user.
                  2. If sudo has been configured to allow Touch ID, a prompt will be shown. See /etc/pam.d/sudo_local.template.
                  3. If sudo requires a password, it will call the helper program specified by the SUDO_ASKPASS environment variable.
                See `man sudo` for more details.
                
                """#
        }
    }
}
