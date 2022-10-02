import XCTest
import MorphologicalAnalysis
import Corpus
@testable import SpellChecker

final class SimpleSpellCheckerTest: XCTestCase {
    
    func testSpellCheck() {
        let fsm = FsmMorphologicalAnalyzer()
        let simpleSpellChecker = SimpleSpellChecker(fsm: fsm)
        let original = [Sentence(sentence: "sırtıkara adındaki canlı , bir balıktır"),
                        Sentence(sentence: "yeni sezon başladı"),
                        Sentence(sentence: "siyah ayı , ayıgiller familyasına ait bir ayı türüdür"),
                        Sentence(sentence: "yeni sezon başladı gibi"),
                        Sentence(sentence: "alışveriş için markete gitti"),
                        Sentence(sentence: "küçük bir yalıçapkını geçti"),
                        Sentence(sentence: "meslek odaları birliği yeniden toplandı"),
                        Sentence(sentence: "yeni yılın sonrasında vakalarda artış oldu"),
                        Sentence(sentence: "atomik saatin 10 mhz sinyali kalibrasyon hizmetlerinde referans olarak kullanılmaktadır"),
                        Sentence(sentence: "rehberimiz bu bölgedeki çıngıraklı yılan varlığı hakkında konuştu"),
                        Sentence(sentence: "bu son model cihaz 24 inç ekran büyüklüğünde ve 9 kg ağırlıktadır")]
        let modified = [Sentence(sentence: "sırtı kara adındaki canlı , bir balıktır"),
                        Sentence(sentence: "yenisezon başladı"),
                        Sentence(sentence: "siyahayı , ayıgiller familyasına ait bir ayı türüdür"),
                        Sentence(sentence: "yeni se zon başladı gibs"),
                        Sentence(sentence: "alis veriş için markete gitit"),
                        Sentence(sentence: "kucuk bri yalı çapkını gecti"),
                        Sentence(sentence: "mes lek odaları birliği yenidün toplandı"),
                        Sentence(sentence: "yeniyılın sonrasında vakalarda artış oldu"),
                        Sentence(sentence: "atomik saatin 10mhz sinyali kalibrasyon hizmetlerinde referans olarka kullanılmaktadır"),
                        Sentence(sentence: "rehperimiz buı bölgedeki çıngıraklıyılan varlıgı hakkınd konustu"),
                        Sentence(sentence: "bu son model ciha 24inç ekran büyüklüğünde ve 9kg ağırlıktadır")]
        for i in 0..<modified.count {
            XCTAssertEqual(original[i].description(), simpleSpellChecker.spellCheck(sentence: modified[i]).description())
        }
    }

    static var allTests = [
        ("testExample", testSpellCheck),
    ]
}
