import XCTest
@testable import TableKit

final class TableRendererTests: XCTestCase {
    let data: TableEncoding.Data = {
        let data = TableEncoding.Data()
        data.rowKeys = ["A", "B", "C"]
        data.columnKeys = ["E", "F", "G"]
        data.dictionary = [
            "A": [
                "E": "A - E",
                "F": "A - F",
                "G": "A - G"
            ],
            "B": [
                "E": "B - E",
                "F": "B - F",
                "G": "B - G"
            ],
            "C": [
                "E": "C - E",
                "F": "C - F",
                "G": "C - G"
            ]
        ]
        return data
    }()
    
    func testDefaultStyleWithoutRowKeys() throws {
        let expected = """
        ┏━━━━━━━┳━━━━━━━┳━━━━━━━┓
        ┃ E     ┃ F     ┃ G     ┃
        ┡━━━━━━━╇━━━━━━━╇━━━━━━━┩
        │ A - E │ A - F │ A - G │
        ├───────┼───────┼───────┤
        │ B - E │ B - F │ B - G │
        ├───────┼───────┼───────┤
        │ C - E │ C - F │ C - G │
        └───────┴───────┴───────┘
        
        """
        
        let style = TableStyle.default
        let output = TableRenderer(style: style).render(data: data)
        XCTAssertEqual(output, expected)
    }
    
    func testDefaultStyleWithRowKeys() throws {
        let expected = """
        ┏━━━┳━━━━━━━┳━━━━━━━┳━━━━━━━┓
        ┃   ┃ E     ┃ F     ┃ G     ┃
        ┡━━━╇━━━━━━━╇━━━━━━━╇━━━━━━━┩
        │ A │ A - E │ A - F │ A - G │
        ├───┼───────┼───────┼───────┤
        │ B │ B - E │ B - F │ B - G │
        ├───┼───────┼───────┼───────┤
        │ C │ C - E │ C - F │ C - G │
        └───┴───────┴───────┴───────┘
        
        """
        
        var style = TableStyle.default
        style.showRowKeys = true
        
        let output = TableRenderer(style: style).render(data: data)
        XCTAssertEqual(output, expected)
    }

    
    func testWhitespaceStyleWithoutRowKeys() throws {
        let expected = """
        E     F     G
        A - E A - F A - G
        B - E B - F B - G
        C - E C - F C - G
        
        """
        
        let style = TableStyle.whitespace
        let output = TableRenderer(style: style).render(data: data)
        XCTAssertEqual(output, expected)
    }
    
    func testWhitespaceStyleWithRowKeys() throws {
        let expected = """
          E     F     G
        A A - E A - F A - G
        B B - E B - F B - G
        C C - E C - F C - G
        
        """
        
        var style = TableStyle.whitespace
        style.showRowKeys = true
        
        let output = TableRenderer(style: style).render(data: data)
        XCTAssertEqual(output, expected)
    }
}
