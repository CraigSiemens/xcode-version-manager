import Foundation

public struct TableStyle {
    /// The style to apply to the header
    public var header: Header
    
    /// The style to apply to the body
    public var body: Body
    
    /// Whether the show keys should be shown or hidden.
    /// /// Defaults to `false`.
    public var showRowKeys: Bool = false
    
    /// Whether a trailing newline should be added following the table.
    /// Defaults to `false`.
    public var addTrailingNewline: Bool = false
    
    /// The amount of padding spaces to add to either side of the values in the table.
    /// Defaults to `0`.
    public var paddingSize: Int = 0
    
    public init(
        header: TableStyle.Header,
        body: TableStyle.Body,
        showRowKeys: Bool = false,
        paddingSize: Int = 0
    ) {
        self.header = header
        self.body = body
        self.showRowKeys = showRowKeys
        self.paddingSize = paddingSize
    }
    
    /// Each column is separated by one or more spaces. There are no characters between the rows.
    public static var whitespace: TableStyle {
        .init(
            header: Header(join: " "),
            body: Body(inner: " ")
        )
    }
    
    /// Uses ``TableStyle.Header.default`` and ``TableStyle.Body.default`` with 1 space of padding in the
    public static var `default`: TableStyle {
        .init(
            header: .default,
            body: .default,
            paddingSize: 1
        )
    }
}

extension TableStyle {
    private struct Box {
        // U+250x    ─    ━    │    ┃    ┄    ┅    ┆    ┇    ┈    ┉    ┊    ┋    ┌    ┍    ┎    ┏
        // U+251x    ┐    ┑    ┒    ┓    └    ┕    ┖    ┗    ┘    ┙    ┚    ┛    ├    ┝    ┞    ┟
        // U+252x    ┠    ┡    ┢    ┣    ┤    ┥    ┦    ┧    ┨    ┩    ┪    ┫    ┬    ┭    ┮    ┯
        // U+253x    ┰    ┱    ┲    ┳    ┴    ┵    ┶    ┷    ┸    ┹    ┺    ┻    ┼    ┽    ┾    ┿
        // U+254x    ╀    ╁    ╂    ╃    ╄    ╅    ╆    ╇    ╈    ╉    ╊    ╋    ╌    ╍    ╎    ╏
        // U+255x    ═    ║    ╒    ╓    ╔    ╕    ╖    ╗    ╘    ╙    ╚    ╛    ╜    ╝    ╞    ╟
        // U+256x    ╠    ╡    ╢    ╣    ╤    ╥    ╦    ╧    ╨    ╩    ╪    ╫    ╬    ╭    ╮    ╯
        // U+257x    ╰    ╱    ╲    ╳    ╴    ╵    ╶    ╷    ╸    ╹    ╺    ╻    ╼    ╽    ╾    ╿
        
        private let rawRepresentation: String
        
        private func string(at index: Int) -> String {
            let stringIndex = rawRepresentation.index(rawRepresentation.startIndex, offsetBy: index)
            let character = rawRepresentation[stringIndex]
            return String(character)
        }
        
        var topLeadingCorner: String { string(at: 0) }
        var top: String { string(at: 1) }
        var topJoin: String { string(at: 2) }
        var topTrailingCorner: String { string(at: 3) }
        
        var leading: String { string(at: 5) }
        var padding: String { string(at: 6) }
        var vertical: String { string(at: 7) }
        var trailing: String { string(at: 8) }
        
        var leadingJoin: String { string(at: 10) }
        var horizontal: String { string(at: 11) }
        var innerJoin: String { string(at: 12) }
        var trailingJoin: String { string(at: 13) }
        
        var bottomLeadingCorner: String { string(at: 15) }
        var bottom: String { string(at: 16) }
        var bottomJoin: String { string(at: 17) }
        var bottomTrailingCorner: String { string(at: 18) }
        
        
        static var lightLine: Box {
            .init(rawRepresentation: """
               ┌─┬┐
               │ ││
               ├─┼┤
               └─┴┘
               """)
        }
        
        static var heavyLine: Box {
            .init(rawRepresentation: """
               ┏━┳┓
               ┃ ┃┃
               ┣━╋┫
               ┗━┻┛
               """)
        }
    }
}
