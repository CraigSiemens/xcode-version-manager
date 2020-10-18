import Foundation

extension Collection {
    func nilIfEmpty() -> Self? {
        isEmpty ? nil : self
    }
}
