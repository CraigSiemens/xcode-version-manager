import Foundation

func askConfirmation(_ question: String, default defaultOption: AskConfirmationOption) -> Bool {
    let yes = defaultOption == .yes ? "Y" : "y"
    let no = defaultOption == .no ? "N" : "n"
    
    print("\(question) [\(yes)/\(no)]")
    
    guard let line = readLine(strippingNewline: true) else { return false }
    
    switch line.count {
    case 0:
        return defaultOption == .yes
    case 1:
        return line.lowercased() == "y"
    default:
        return false
    }
}

enum AskConfirmationOption {
    case yes, no
}
