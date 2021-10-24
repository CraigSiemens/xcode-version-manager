import Foundation

public struct TableStyle {
    public var header: Header
    public var body: Body
    
    public var showRowKeys: Bool = false
    public var addTrailingNewline: Bool = false
    public var paddingSize: Int = 0
    
    public init(header: TableStyle.Header, body: TableStyle.Body, showRowKeys: Bool = false, paddingSize: Int = 0) {
        self.header = header
        self.body = body
        self.showRowKeys = showRowKeys
        self.paddingSize = paddingSize
    }
    
    public static var whitespace: TableStyle {
        .init(header: Header(join: " "),
              body: Body(inner: " "))
    }
    
    public static var `default`: TableStyle {
        .init(header: .default,
              body: .default,
              paddingSize: 1)
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
