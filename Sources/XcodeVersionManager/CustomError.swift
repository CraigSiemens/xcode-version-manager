import Foundation

struct CustomError: LocalizedError {
    let localizedDescription: String
    
    var errorDescription: String? {
        localizedDescription
    }
    
    init(_ localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }
}
