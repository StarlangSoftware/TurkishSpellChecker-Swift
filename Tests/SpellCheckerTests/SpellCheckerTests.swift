import XCTest
@testable import SpellChecker

final class SpellCheckerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SpellChecker().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
