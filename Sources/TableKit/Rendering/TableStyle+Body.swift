import Foundation

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
        
        public init(
            leading: String = "",
            inner: String = "",
            trailing: String = "",
            leadingJoin: String = "",
            innerJoin: String = "",
            trailingJoin: String = "",
            bottomLeadingCorner: String = "",
            bottom: String = "",
            bottomJoin: String = "",
            bottomTrailingCorner: String = ""
        ) {
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
            .init(
                leading: "│",
                inner: "│",
                trailing: "│",
                leadingJoin: "├",
                innerJoin: "┼",
                trailingJoin: "┤",
                bottomLeadingCorner: "└",
                bottom: "─",
                bottomJoin: "┴",
                bottomTrailingCorner: "┘"
            )
        }
    }
}
