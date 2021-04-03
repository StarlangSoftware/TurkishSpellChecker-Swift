import XCTest
import MorphologicalAnalysis
import Corpus
@testable import SpellChecker

final class SimpleSpellCheckerTest: XCTestCase {
    
    func testSpellCheck() {
        let fsm = FsmMorphologicalAnalyzer()
        let simpleSpellChecker = SimpleSpellChecker(fsm: fsm)
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let url = thisDirectory.appendingPathComponent("misspellings.txt")
        do{
            let fileContent = try String(contentsOf: url, encoding: .utf8)
            let lines : [String] = fileContent.split(whereSeparator: \.isNewline).map(String.init)
            for line in lines{
                let wordList : [String] = line.split(separator: " ").map(String.init)
                XCTAssertEqual(wordList[1], simpleSpellChecker.spellCheck(sentence: Sentence(sentence: wordList[0])).description())
            }
        }catch{
        }
    }

    static var allTests = [
        ("testExample", testSpellCheck),
    ]
}
