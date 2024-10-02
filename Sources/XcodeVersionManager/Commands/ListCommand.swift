import ArgumentParser
import Foundation
import TableKit

struct ListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Lists the installed versions of Xcode."
    )
    
    func run() async throws {
        let formatter = XcodeVersionFormatter()
        
        let current = try XcodeApplication.current()
        
        let formattedValues = try await XcodeApplication
            .all()
            .sorted(by: <)
            .map {
                FormattedXcodeApplication(
                    current: $0 == current ? "*" : " ",
                    formattedVersion: formatter.string(from: $0),
                    buildNumber: $0.buildNumber,
                    name: $0.url.lastPathComponent
                )
            }
        
        let style = TableStyle(header: .inside, body: .inside, paddingSize: 1)
        let encoder = TableEncoder(style: style)
        print(try encoder.encode(formattedValues))
    }
}

// MARK: - FormattedXcodeApplication
private struct FormattedXcodeApplication: Encodable {
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
