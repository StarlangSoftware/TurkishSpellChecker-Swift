import XCTest
import MorphologicalAnalysis
import Corpus
import NGram
@testable import SpellChecker

final class NGramSpellCheckerTest: XCTestCase {
    
    func testSpellCheck() {
        let fsm = FsmMorphologicalAnalyzer()
        let nGram = NGram<String>(fileName: "ngram.txt")
        let smoothing = NoSmoothing<String>()
        nGram.calculateNGramProbabilitiesSimple(simpleSmoothing: smoothing)
        let original = [Sentence(sentence: "demokratik cumhuriyet en kıymetli varlığımızdır"),
                        Sentence(sentence: "bu tablodaki değerler zedelenmeyecektir"),
                        Sentence(sentence: "milliyet'in geleneksel yılın sporcusu anketi 43. yaşını doldurdu"),
                Sentence(sentence: "demokrasinin icadı bu ayrımı bulandırdı"),
                Sentence(sentence: "dışişleri müsteşarı Öymen'in 1997'nin ilk aylarında Bağdat'a gitmesi öngörülüyor"),
                Sentence(sentence: "büyüdü , palazlandı , devleti ele geçirdi"),
                Sentence(sentence: "her maskenin ciltte kalma süresi farklıdır"),
                Sentence(sentence: "yılın son ayında 10 gazeteci gözaltına alındı"),
                Sentence(sentence: "iki pilotun kullandığı uçakta bir hostes görev alıyor"),
                Sentence(sentence: "son derece kısıtlı kelimeler çerçevesinde kendilerini uzun cümlelerle ifade edebiliyorlar"),
                Sentence(sentence: "kedi köpek"),
                Sentence(sentence: "minibüs durağı"),
                Sentence(sentence: "noter belgesi"),
                Sentence(sentence: "")]
        let modified = [Sentence(sentence: "demokratik cumhüriyet rn kımetli varlıgımızdır"),
                        Sentence(sentence: "bu tblodaki değerlğr zedelenmeyecüktir"),
                        Sentence(sentence: "milliyet'in geeneksel yılin spoşcusu ankşti 43. yeşını doldürdu"),
                Sentence(sentence: "demokrasinin icşdı buf ayrmıı bulandürdı"),
                Sentence(sentence: "dışişleri mütseşarı Öymen'in 1997'nin iljk aylğrında Bağdat'a gitmesi öngörülüyor"),
                Sentence(sentence: "büyüdü , palazandı , devltei eöe geçridi"),
                Sentence(sentence: "her makenin cültte aklma sürdsi farlkıdır"),
                Sentence(sentence: "yılın sno ayında 10 gazteci gözlatına alündı"),
                Sentence(sentence: "iki piotun kulçandığı uçkata üir hotes görçv alyıor"),
                Sentence(sentence: "son deece kısütlı keilmeler çeçevesinde kendülerini uzuü cümllerle ifüde edbeiliyorlar"),
                Sentence(sentence: "krdi köpek"),
                Sentence(sentence: "minibü durağı"),
                Sentence(sentence: "ntoer belgesi"),
                Sentence(sentence: "")]
        let nGramSpellChecker = NGramSpellChecker(fsm: fsm, nGram: nGram, rootNGram: true)
        for i in 0..<modified.count {
            XCTAssertEqual(original[i].description(), nGramSpellChecker.spellCheck(sentence: modified[i]).description())
        }
    }

    static var allTests = [
        ("testExample", testSpellCheck),
    ]
}
