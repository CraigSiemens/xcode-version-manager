import Foundation

func askConfirmation(_ question: String, default defaultOption: AskConfirmationOption) -> Bool {
    var yes = AskConfirmationOption.yes.short
    if defaultOption == .yes {
        yes = yes.uppercased()
    }
    
    var no = AskConfirmationOption.no.short
    if defaultOption == .no {
        no = no.uppercased()
    }
    
    print("\(question) [\(yes)/\(no)]")
    
    guard let line = readLine(strippingNewline: true)?.lowercased() else { return false }
    
    guard !line.isEmpty else {
        // Print the default option on the previous line
        print("\u{01B}[F\(defaultOption)")
        return defaultOption == .yes
    }
    
    if AskConfirmationOption.yes.name.hasPrefix(line) {
        // Print the selected option on the previous line
        print("\u{01B}[F\(AskConfirmationOption.yes)")
        return true
    } else if AskConfirmationOption.no.name.hasPrefix(line) {
        // Print the selected option on the previous line
        print("\u{01B}[F\(AskConfirmationOption.no)")
        return false
    } else {
        return false
    }
}

struct AskConfirmationOption: Equatable, CustomStringConvertible {
    fileprivate let name: String
    fileprivate var short: String { String(name.prefix(1)) }
    var description: String { name }
    
    static let yes = Self(name: "yes")
    static let no = Self(name: "no")
}
