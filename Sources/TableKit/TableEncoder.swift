import Foundation

/// An object that encodes instances of a data type into a text based table.
///
/// The `CodingKey` will be used for the values of the row and column headers.
public struct TableEncoder {
    public typealias Output = String
    
    public var style: TableStyle
    
    public init(style: TableStyle = .default) {
        self.style = style
    }
    
    public func encode<T>(_ value: T) throws -> Output where T : Encodable {
        let encoder = TableEncoding()
        try value.encode(to: encoder)
        return TableRenderer(style: style).render(data: encoder.data)
    }
}
