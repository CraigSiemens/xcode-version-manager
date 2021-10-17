import Foundation

struct TableRenderer {
    let style: TableStyle
    
    func render(data: TableEncoding.Data) -> String {
        let leadingColumnWidth = (data.rowKeys.map { $0.count }.max() ?? 0)
            + style.paddingSize * 2
        
        let columnWidths = data.dictionary.values
            .map { (value) in
                value.mapValues { $0.count + style.paddingSize * 2 }
            }
            .reduce(into: [String: Int]()) { (result, row) in
                result.merge(row) { max($0, $1) }
            }
        
        var orderedWidths = data.columnKeys.map { columnWidths[$0] ?? $0.count }
        if style.showRowKeys {
            orderedWidths.insert(leadingColumnWidth, at: 0)
        }
        
        var output: String = ""
        
        func addHorizontalLine(line: String, leading: String, join: String, trailing: String) {
            let startingLength = output.count
            
            output += leading
            
            output += orderedWidths
                .map { String(repeating: line, count: $0) }
                .joined(separator: join)
            
            output += trailing
            
            if startingLength != output.count {
                output += "\n"
            }
        }
        
        func addValuesLine(values: [String], leading: String, join: String, trailing: String) {
            let padding = String(repeating: " ", count: style.paddingSize)
            
            output += leading + padding
            
            output += zip(values, orderedWidths)
                .map { $0.0.padding(toLength: $0.1 - style.paddingSize * 2, withPad: " ", startingAt: 0) }
                .joined(separator: padding + join + padding)
            
            output += padding + trailing
            output += "\n"
        }
        
        // MARK: - Header
        addHorizontalLine(line: style.header.top,
                          leading: style.header.topLeadingCorner,
                          join: style.header.topJoin,
                          trailing: style.header.topTrailingCorner)
        
        addValuesLine(values: data.columnKeys,
                      leading: style.header.leading,
                      join: style.header.join,
                      trailing: style.header.trailing)
        
        addHorizontalLine(line: style.header.bottom,
                          leading: style.header.bottomLeadingCorner,
                          join: style.header.bottomJoin,
                          trailing: style.header.bottomTrailingCorner)
        
        // MARK: - Rows
        for rowKey in data.rowKeys {
            let rowValues = data.columnKeys.map { data.dictionary[rowKey]?[$0] ?? "" }
            
            addValuesLine(values: rowValues,
                          leading: style.body.leading,
                          join: style.body.inner,
                          trailing: style.body.trailing)
            
            if rowKey == data.rowKeys.last {
                addHorizontalLine(line: style.body.bottom,
                                  leading: style.body.bottomLeadingCorner,
                                  join: style.body.bottomJoin,
                                  trailing: style.body.bottomTrailingCorner)

            } else {
                addHorizontalLine(line: style.body.bottom,
                                  leading: style.body.leadingJoin,
                                  join: style.body.innerJoin,
                                  trailing: style.body.trailingJoin)
            }
        }
        
        if output.last != "\n" {
            output += "\n"
        }
        
        return output
    }
}
