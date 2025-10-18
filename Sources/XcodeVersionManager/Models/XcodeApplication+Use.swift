import Foundation
import RegexBuilder

extension XcodeApplication {
    enum XcodeSelectPermissions {
        case inherit
        case sudoAskpass
    }
    
    func use(permissions: XcodeSelectPermissions) throws(UseError) {
        let xcodePath = url.absoluteURL.path
        
        switch permissions {
        case .inherit:
            // Get the current user id to determine if being run as root
            let userId = try execute(
                "/usr/bin/id",
                arguments: ["-u"]
            )
            
            let command = "/usr/bin/xcode-select"
            let arguments = [
                "--switch",
                xcodePath
            ]
            
            // Is root user
            if String(decoding: userId, as: UTF8.self) == "0" {
                // Works if xcvm is run with superuser permissions
                try execute(command, arguments: arguments)
            } else {
                var command = "/usr/bin/sudo \(command)"
                for argument in arguments {
                    let argument = if argument.contains(.whitespace) {
                        "'\(argument)'"
                    } else {
                        argument
                    }
                    
                    command += " \(argument)"
                }
                
                throw .sudoRequired(command: command)
            }
        case .sudoAskpass:
            // Works if
            //   xcode-select has NOPASSWD set in sudoers
            //   touchid is enabled for sudo
            //   SUDO_ASKPASS environment variable is set with a helper program
            // otherwise fails to prompt for password
            try execute(
                "/usr/bin/sudo",
                arguments: [
                    "--askpass",
                    "/usr/bin/xcode-select",
                    "--switch",
                    xcodePath
                ]
            )
        }
        
        // Register Xcode so plugins work correctly.
        // https://nshipster.com/xcode-source-extensions/#using-pluginkit
        try execute(
            "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
            arguments: [
                "-f",
                xcodePath
            ]
        )
    }
    
    @discardableResult
    private func execute(_ command: String, arguments: [String]) throws(UseError) -> Data {
        do {
            return try Process.execute(command, arguments: arguments)
        } catch {
            throw .other(error)
        }
    }
}

extension XcodeApplication {
    enum UseError: LocalizedError {
        case sudoRequired(command: String)
        case other(Error)
        
        var errorDescription: String? {
            switch self {
            case let .sudoRequired(command):
                return command
            case let .other(error):
                return String(describing: error)
            }
        }
    }
}
