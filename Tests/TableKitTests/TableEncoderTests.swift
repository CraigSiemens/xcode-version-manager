import XCTest
@testable import TableKit

final class TableEncoderTests: XCTestCase {
    let encoder = TableEncoder(style: .whitespace)
    
    func testEncodingPrimitives() {
        let data = [
            ["A": 1],
            ["B": 2]
        ]
        let expected = [
            "  A B\n",
            "0 1  \n",
            "1   2\n"
        ].joined()
        
        let output = try? encoder.encode(data)
        XCTAssertEqual(output, expected)
    }
    
    func testEncodingStructs() {
        let characters: [Character] = [
            .init(name: "Mario", color: "red", size: "medium"),
            .init(name: "Yoshi", color: "green", size: "small"),
            .init(name: "Bowser", color: "orange", size: "large")
        ]
        let expected = [
            "  name   color  size  \n",
            "0 Mario  red    medium\n",
            "1 Yoshi  green  small \n",
            "2 Bowser orange large \n"
        ].joined()

        let output = try? encoder.encode(characters)
        XCTAssertEqual(output, expected)
    }

    func testEncodingArrays() {
        let data = [
            ["A", "B", "C"],
            ["D", "E", "F"]
        ]
        let expected = [
            "  name   color  size  \n",
            "0 Mario  red    medium\n",
            "1 Yoshi  green  small \n",
            "2 Bowser orange large \n"
        ].joined()

        let output = try? encoder.encode(data)
        print(output!)
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
