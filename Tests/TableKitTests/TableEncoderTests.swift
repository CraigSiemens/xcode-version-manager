import XCTest
@testable import TableKit

final class TableEncoderTests: XCTestCase {
    var encoder = TableEncoder(style: .whitespace)
    
    func testEncodingPrimitives() throws {
        let data = [
            ["A": 1],
            ["B": 2]
        ]
        let expected = [
            "A B\n",
            "1  \n",
            "  2\n"
        ].joined()
        
        let output = try encoder.encode(data)
        XCTAssertEqual(output, expected)
    }
    
    func testEncodingStructs() throws {
        let characters: [Character] = [
            .init(name: "Mario", color: "red", size: "medium"),
            .init(name: "Yoshi", color: "green", size: "small"),
            .init(name: "Bowser", color: "orange", size: "large")
        ]
        let expected = [
            "name   color  size  \n",
            "Mario  red    medium\n",
            "Yoshi  green  small \n",
            "Bowser orange large \n"
        ].joined()
        
        let output = try encoder.encode(characters)
        XCTAssertEqual(output, expected)
    }
    
    func testEncodingArrays() throws {
        let data = [
            ["A", "B", "C"],
            ["D", "E", "F"]
        ]
        let expected = [
            "0 1 2\n",
            "A B C\n",
            "D E F\n"
        ].joined()
        
        let output = try encoder.encode(data)
        XCTAssertEqual(output, expected)
    }
    
    static var allTests = [
        ("testEncodingPrimitives", testEncodingPrimitives),
        ("testEncodingStructs", testEncodingStructs),
    ]
}

struct Character: Encodable {
    let name: String
    let color: String
    let size: String
}
