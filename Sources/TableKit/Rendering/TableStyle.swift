import Foundation

public struct TableStyle {
    public var header: Header
    public var body: Body
    
    public var showRowKeys: Bool = false
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
    public struct Header {
        var topLeadingCorner: String = ""
        var top: String = ""
        var topJoin: String = ""
        var topTrailingCorner: String = ""
                
        var leading: String = ""
        var join: String = ""
        var trailing: String = ""
        
        var bottomLeadingCorner: String = ""
        var bottom: String = ""
        var bottomJoin: String = ""
        var bottomTrailingCorner: String = ""
        
        public init(topLeadingCorner: String = "", top: String = "", topJoin: String = "", topTrailingCorner: String = "", leading: String = "", join: String = "", trailing: String = "", bottomLeadingCorner: String = "", bottom: String = "", bottomJoin: String = "", bottomTrailingCorner: String = "") {
            self.topLeadingCorner = topLeadingCorner
            self.top = top
            self.topJoin = topJoin
            self.topTrailingCorner = topTrailingCorner
            self.leading = leading
            self.join = join
            self.trailing = trailing
            self.bottomLeadingCorner = bottomLeadingCorner
            self.bottom = bottom
            self.bottomJoin = bottomJoin
            self.bottomTrailingCorner = bottomTrailingCorner
        }
        
        static var `default`: Header {
            .init(topLeadingCorner: "┏",
                  top: "━",
                  topJoin: "┳",
                  topTrailingCorner: "┓",
                  leading: "┃",
                  join: "┃",
                  trailing: "┃",
                  bottomLeadingCorner: "┡",
                  bottom: "━",
                  bottomJoin: "╇",
                  bottomTrailingCorner: "┩")
        }
    }
}

extension TableStyle {
    public struct Body {
        var leading: String = ""
        var inner: String = ""
        var trailing: String = ""
        
        var leadingJoin: String = ""
        var innerJoin: String = ""
        var trailingJoin: String = ""
        
        var bottomLeadingCorner: String = ""
        var bottom: String = ""
        var bottomJoin: String = ""
        var bottomTrailingCorner: String = ""
        
        public init(leading: String = "", inner: String = "", trailing: String = "", leadingJoin: String = "", innerJoin: String = "", trailingJoin: String = "", bottomLeadingCorner: String = "", bottom: String = "", bottomJoin: String = "", bottomTrailingCorner: String = "") {
            self.leading = leading
            self.inner = inner
            self.trailing = trailing
            self.leadingJoin = leadingJoin
            self.innerJoin = innerJoin
            self.trailingJoin = trailingJoin
            self.bottomLeadingCorner = bottomLeadingCorner
            self.bottom = bottom
            self.bottomJoin = bottomJoin
            self.bottomTrailingCorner = bottomTrailingCorner
        }
        
        static var `default`: Body {
            .init(leading: "│",
                  inner: "│",
                  trailing: "│",
                  leadingJoin: "├",
                  innerJoin: "┼",
                  trailingJoin: "┤",
                  bottomLeadingCorner: "└",
                  bottom: "─",
                  bottomJoin: "┴",
                  bottomTrailingCorner: "┘")
        }
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
