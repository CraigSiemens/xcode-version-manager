import Foundation

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
        
        public init(
            topLeadingCorner: String = "",
            top: String = "",
            topJoin: String = "",
            topTrailingCorner: String = "",
            leading: String = "",
            join: String = "",
            trailing: String = "",
            bottomLeadingCorner: String = "",
            bottom: String = "",
            bottomJoin: String = "",
            bottomTrailingCorner: String = ""
        ) {
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
            .init(
                topLeadingCorner: "┏",
                top: "━",
                topJoin: "┳",
                topTrailingCorner: "┓",
                leading: "┃",
                join: "┃",
                trailing: "┃",
                bottomLeadingCorner: "┡",
                bottom: "━",
                bottomJoin: "╇",
                bottomTrailingCorner: "┩"
            )
        }
    }
}
