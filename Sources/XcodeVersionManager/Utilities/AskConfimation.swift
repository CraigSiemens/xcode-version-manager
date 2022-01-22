import Foundation

func askConfirmation(_ question: String) -> Bool {
    print("\(question) [y/N]")
    
    return readLine(strippingNewline: true)?.lowercased() == "y"
}
