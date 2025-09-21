import ArgumentParser
import Foundation
import TableKit

struct ListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Lists versions of Xcode.",
        subcommands: [
            InstalledCommand.self,
            KnownCommand.self
        ],
        defaultSubcommand: InstalledCommand.self
    )
}

extension ListCommand {
    struct InstalledCommand: AsyncParsableCommand {
        static let configuration: CommandConfiguration = .init(
            commandName: "installed",
            abstract: "Lists the installed versions of Xcode."
        )
        
        func run() async throws {
            let formatter = XcodeVersionFormatter()
            
            let current = try XcodeApplication.current()
            
            let rows = try await XcodeApplication
                .all()
                .sorted(by: >)
                .map {
                    Row(
                        current: $0 == current ? "*" : " ",
                        formattedVersion: formatter.string(from: $0),
                        buildNumber: $0.buildNumber,
                        name: $0.url.lastPathComponent
                    )
                }
            
            let style = TableStyle(header: .inside, body: .inside, paddingSize: 1)
            let encoder = TableEncoder(style: style)
            print(try encoder.encode(rows))
        }
        
        private struct Row: Encodable {
            let current: String
            let formattedVersion: String
            let buildNumber: String
            let name: String
            
            enum CodingKeys: String, CodingKey {
                case current = ""
                case formattedVersion = "Version"
                case buildNumber = "Build"
                case name = "Name"
            }
        }
    }
}

extension ListCommand {
    struct KnownCommand: AsyncParsableCommand {
        static let configuration: CommandConfiguration = .init(
            commandName: "known",
            abstract: "Lists the known versions of Xcode."
        )
        
        func run() async throws {
            let rows = try await XcodeReleasesAPI
                .releases()
                .map {
                    Row(
                        formattedVersion: $0.version.formatted(style: .pretty),
                        buildNumber: $0.version.build,
                        requires: $0.requires.formatted(),
                        architectures: $0.download.architectures
                            .map(\.rawValue)
                            .joined(separator: ", ")
                    )
                }
            
            let style = TableStyle(header: .inside, body: .inside, paddingSize: 1)
            let encoder = TableEncoder(style: style)
            print(try encoder.encode(rows))
        }
        
        private struct Row: Encodable {
            let formattedVersion: String
            let buildNumber: String
            let requires: String
            let architectures: String
            
            enum CodingKeys: String, CodingKey {
                case formattedVersion = "Version"
                case buildNumber = "Build"
                case requires = "Requires"
                case architectures = "Architectures"
            }
        }
    }
}

private extension TableStyle.Header {
    static var inside: TableStyle.Header {
        .init(
            join: "┃",
            bottom: "━",
            bottomJoin: "╇"
        )
    }
}

private extension TableStyle.Body {
    static var inside: TableStyle.Body {
        .init(inner: "│")
    }
}

extension OperatingSystemVersion {
    func formatted() -> String {
        var parts: [Int] = [
            majorVersion, minorVersion
        ]
        
        if patchVersion != 0 { parts.append(patchVersion) }
        
        return parts.map(String.init).joined(separator: ".")
    }
}
