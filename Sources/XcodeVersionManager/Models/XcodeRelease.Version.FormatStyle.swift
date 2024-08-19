import Foundation

extension XcodeRelease.Version {
    func formatted() -> String {
        formatted(style: .pretty)
    }
    
    func formatted(style: FormatStyle.Style) -> String {
        FormatStyle(style: style).format(self)
    }
    
    struct FormatStyle: Foundation.FormatStyle, Codable {
        typealias FormatInput = XcodeRelease.Version
        typealias FormatOutput = String
        
        enum Style: String, Codable {
            case pretty, fileName, option
        }
        
        var style: Style = .pretty
        
        func format(_ value: FormatInput) -> FormatOutput {
            var string = switch value.release {
            case .beta(0):
                "\(value.number) Beta"
            case .beta(let number):
                "\(value.number) Beta \(number)"
            case .rc(0):
                "\(value.number) RC"
            case .rc(let number):
                "\(value.number) RC \(number)"
            case .release:
                value.number
            }
            
            switch style {
            case .pretty:
                break
            case .fileName:
                string = string
                    .replacingOccurrences(of: " ", with: "-")
                    .replacingOccurrences(of: ".", with: "-")
                    .lowercased()
            case .option:
                string = string
                    .replacingOccurrences(of: " ", with: "-")
                    .lowercased()
            }
            
            return string
        }
    }
}
