import Foundation

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
