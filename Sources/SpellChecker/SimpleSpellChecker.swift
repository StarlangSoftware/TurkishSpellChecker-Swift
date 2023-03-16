//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.04.2021.
//

import Foundation
import MorphologicalAnalysis
import Dictionary
import Corpus

public class SimpleSpellChecker : SpellChecker{

    var fsm: FsmMorphologicalAnalyzer
    var mergedWords: [String : String] = [:]
    var splitWords: [String : String] = [:]
    var shortcuts: [String] = ["cc", "cm2", "cm", "gb", "ghz", "gr", "gram", "hz", "inc", "inch", "inç",
                               "kg", "kw", "kva", "litre", "lt", "m2", "m3", "mah", "mb", "metre", "mg", "mhz", "ml", "mm", "mp", "ms", "mt", "mv", "tb", "tl", "va", "volt", "watt", "ah", "hp", "oz", "rpm", "dpi", "ppm", "ohm", "kwh", "kcal", "kbit", "mbit", "gbit", "bit", "byte", "mbps", "gbps", "cm3", "mm2", "mm3", "khz", "ft", "db", "sn"]
    var conditionalShortcuts: [String] = ["g", "v", "m", "l", "w", "s"]
    var questionSuffixList: [String] = ["mi", "mı", "mu", "mü", "miyim", "misin", "miyiz", "midir", "miydi", "mıyım", "mısın", "mıyız", "mıdır", "mıydı", "muyum", "musun", "muyuz", "mudur", "muydu", "müyüm", "müsün", "müyüz", "müdür", "müydü", "miydim", "miydin", "miydik", "miymiş", "mıydım", "mıydın", "mıydık", "mıymış", "muydum", "muydun", "muyduk", "muymuş", "müydüm", "müydün", "müydük", "müymüş", "misiniz", "mısınız", "musunuz", "müsünüz", "miyimdir", "misindir", "miyizdir", "miydiniz", "miydiler", "miymişim", "miymişiz", "mıyımdır", "mısındır", "mıyızdır", "mıydınız", "mıydılar", "mıymışım", "mıymışız", "muyumdur", "musundur", "muyuzdur", "muydunuz", "muydular", "muymuşum", "muymuşuz", "müyümdür", "müsündür", "müyüzdür", "müydünüz", "müydüler", "müymüşüm", "müymüşüz", "miymişsin", "miymişler", "mıymışsın", "mıymışlar", "muymuşsun", "muymuşlar", "müymüşsün", "müymüşler", "misinizdir", "mısınızdır", "musunuzdur", "müsünüzdür"]
    
    /**
     * A constructor of {@link SimpleSpellChecker} class which takes a {@link FsmMorphologicalAnalyzer} as an input and
     * assigns it to the fsm variable.
     - Parameters:
        - fsm: {@link FsmMorphologicalAnalyzer} type input.
     */
    public init(fsm: FsmMorphologicalAnalyzer){
        self.fsm = fsm
        loadDictionaries()
    }

    private func replaceChar(word: String, index: Int, char: String) -> String{
        if index > 0{
            return String(word.prefix(index)) + char + word.dropFirst(index + 1)
        } else {
            return char + word.dropFirst()
        }
    }

    private func deleteChar(word: String, index: Int) -> String{
        if index > 0{
            return String(word.prefix(index)) + word.dropFirst(index + 1)
        } else {
            return String(word.dropFirst())
        }
    }

    private func swapChar(word: String, index: Int) -> String{
        if index > 0{
            return String(word.prefix(index)) + String(Word.charAt(s: word, i: index + 1)) + String(Word.charAt(s: word, i: index)) + word.dropFirst(index + 2)
        } else {
            return String(Word.charAt(s: word, i: 1)) + String(Word.charAt(s: word, i: 0)) + word.dropFirst(2)
        }
    }

    private func addChar(word: String, index: Int, char: String) -> String{
        if index > 0{
            return String(word.prefix(index)) + char + word.dropFirst(index)
        } else {
            return char + word
        }
    }

    /**
     * The generateCandidateList method takes a String as an input. Firstly, it creates a String consists of lowercase Turkish letters
     * and an {@link ArrayList} candidates. Then, it loops i times where i ranges from 0 to the length of given word. It gets substring
     * from 0 to ith index and concatenates it with substring from i+1 to the last index as a new String called deleted. Then, adds
     * this String to the candidates {@link ArrayList}. Secondly, it loops j times where j ranges from 0 to length of
     * lowercase letters String and adds the jth character of this String between substring of given word from 0 to ith index
     * and the substring from i+1 to the last index, then adds it to the candidates {@link ArrayList}. Thirdly, it loops j
     * times where j ranges from 0 to length of lowercase letters String and adds the jth character of this String between
     * substring of given word from 0 to ith index and the substring from i to the last index, then adds it to the candidates {@link ArrayList}.
        - Parameters:
            - word: String input.
        - Returns: ArrayList candidates.
     */
    private func generateCandidateList(word: String) -> [Candidate]{
        let s = TurkishLanguage.LOWERCASE_LETTERS;
        var candidates : [Candidate] = []
        for i in 0..<word.count {
            if i < word.count - 1{
                let swapped = swapChar(word: word, index: i)
                candidates.append(Candidate(candidate: swapped, _operator: Operator.SPELL_CHECK))
            }
            if TurkishLanguage.LETTERS.contains(Word.charAt(s: word, i: i)) || "wxq".contains(Word.charAt(s: word, i: i)){
                let deleted = deleteChar(word: word, index: i)
                candidates.append(Candidate(candidate: deleted, _operator: Operator.SPELL_CHECK))
                for j in 0..<s.count {
                    let replaced = replaceChar(word: word, index: i, char: String(Word.charAt(s: s, i: j)))
                    candidates.append(Candidate(candidate: replaced, _operator: Operator.SPELL_CHECK));
                }
                for j in 0..<s.count {
                    let added = addChar(word: word, index: i, char: String(Word.charAt(s: s, i: j)))
                    candidates.append(Candidate(candidate: added, _operator: Operator.SPELL_CHECK))
                }
            }
        }
        return candidates;
    }
    
    /**
     * The candidateList method takes a {@link Word} as an input and creates a candidates {@link ArrayList} by calling generateCandidateList
     * method with given word. Then, it loop i times where i ranges from 0 to size of candidates {@link ArrayList} and creates a
     * {@link FsmParseList} by calling morphologicalAnalysis with each item of candidates {@link ArrayList}. If the size of
     * {@link FsmParseList} is 0, it then removes the ith item.
     - Parameters:
        - word: Word input.
     - Returns: candidates {@link ArrayList}.
     */
    public func candidateList(word: Word) -> [Candidate]{
        var candidates: [Candidate] = []
        candidates = generateCandidateList(word: word.getName())
        var i : Int = 0
        while i < candidates.count {
            let fsmParseList = fsm.morphologicalAnalysis(surfaceForm: candidates[i].getName())
            if fsmParseList.size() == 0 {
                let newCandidate = fsm.getDictionary().getCorrectForm(misspelledWord: candidates[i].getName())
                if newCandidate != "" && fsm.morphologicalAnalysis(surfaceForm: newCandidate).size() > 0{
                    candidates[i] = Candidate(candidate: newCandidate, _operator: Operator.MISSPELLED_REPLACE)
                } else {
                    candidates.remove(at: i)
                    i -= 1
                }
            }
            i += 1
        }
        return candidates
    }

    /**
     * The spellCheck method takes a {@link Sentence} as an input and loops i times where i ranges from 0 to size of words in given sentence.
     * Then, it calls morphologicalAnalysis method with each word and assigns it to the {@link FsmParseList}, if the size of
     * {@link FsmParseList} is equal to the 0, it adds current word to the candidateList and assigns it to the candidates {@link ArrayList}.
     * if the size of candidates greater than 0, it generates a random number and selects an item from candidates {@link ArrayList} with
     * this random number and assign it as newWord. If the size of candidates is not greater than 0, it directly assigns the
     * current word as newWord. At the end, it adds the newWord to the result {@link Sentence}.
     - Parameters:
        - sentence: {@link Sentence} type input.
     - Returns: Sentence result.
     */
    func spellCheck(sentence: Sentence) -> Sentence {
        let result : Sentence = Sentence()
        var i : Int = 0
        while i < sentence.wordCount() {
            let word = sentence.getWord(index: i)
            var nextWord : Word? = nil
            var previousWord : Word? = nil
            var newWord : Word
            if i > 0{
                previousWord = sentence.getWord(index: i - 1)
            }
            if i < sentence.wordCount() - 1{
                nextWord = sentence.getWord(index: i + 1)
            }
            if forcedMisspellCheck(word: word, result: result) || forcedBackwardMergeCheck(word: word, result: result, previousWord: previousWord) || forcedSuffixMergeCheck(word: word, result: result, previousWord: previousWord){
                i = i + 1
                continue
            }
            if forcedForwardMergeCheck(word: word, result: result, nextWord: nextWord) || forcedHyphenMergeCheck(word: word, result: result, previousWord: previousWord, nextWord: nextWord){
                i = i + 2
                continue
            }
            if forcedSplitCheck(word: word, result: result) || forcedShortcutSplitCheck(word: word, result: result) || forcedDeDaSplitCheck(word: word, result: result) || forcedQuestionSuffixSplitCheck(word: word, result: result){
                i = i + 1
                continue
            }
            let fsmParseList = fsm.morphologicalAnalysis(surfaceForm: word.getName())
            let upperCaseFsmParseList = fsm.morphologicalAnalysis(surfaceForm: Word.toCapital(s: word.getName()))
            if fsmParseList.size() == 0 && upperCaseFsmParseList.size() == 0{
                var candidates : [Candidate] = mergedCandidatesList(previousWord: previousWord, word: word, nextWord: nextWord)
                if candidates.count < 1{
                    candidates = candidateList(word: word)
                }
                if candidates.count < 1{
                    candidates += splitCandidatesList(word: word)
                }
                if candidates.count > 0 {
                    let randomCandidate = Int.random(in: 0..<candidates.count)
                    newWord = Word(name: candidates[randomCandidate].getName())
                    if (candidates[randomCandidate].getOperator() == Operator.BACKWARD_MERGE){
                        result.replaceWord(i: i - 1, newWord: newWord)
                        i = i + 1
                        continue
                    }
                    if (candidates[randomCandidate].getOperator() == Operator.FORWARD_MERGE){
                        i = i + 1
                    }
                    if (candidates[randomCandidate].getOperator() == Operator.SPLIT){
                        addSplitWords(multiWord: candidates[randomCandidate].getName(), result: result)
                        i = i + 1
                        continue
                    }
                } else {
                    newWord = word
                }
            } else {
                newWord = word
            }
            result.addWord(word: newWord)
            i = i + 1
        }
        return result
    }
    
    public func forcedMisspellCheck(word: Word, result: Sentence)-> Bool{
        let forcedReplacement = fsm.getDictionary().getCorrectForm(misspelledWord: word.getName())
        if forcedReplacement != ""{
            result.addWord(word: Word(name: forcedReplacement))
            return true
        }
        return false
    }
    
    public func forcedBackwardMergeCheck(word: Word, result: Sentence, previousWord: Word?)->Bool{
        if previousWord != nil{
            let forcedReplacement = getCorrectForm(wordName: result.getWord(index: result.wordCount() - 1).getName() + " " + word.getName(), dictionary: mergedWords)
            if forcedReplacement != ""{
                result.replaceWord(i: result.wordCount() - 1, newWord: Word(name: forcedReplacement!))
                return true
            }
        }
        return false
    }
    
    public func forcedForwardMergeCheck(word: Word, result: Sentence, nextWord: Word?)->Bool{
        if nextWord != nil{
            let forcedReplacement = getCorrectForm(wordName: word.getName() + " " + nextWord!.getName(), dictionary: mergedWords)
            if forcedReplacement != ""{
                result.addWord(word: Word(name: forcedReplacement!))
                return true
            }
        }
        return false
    }
    
    public func addSplitWords(multiWord: String, result: Sentence){
        let words = multiWord.split(separator: " ")
        for word in words {
            result.addWord(word: Word(name: String(word)))
        }
    }
    
    public func forcedSplitCheck(word: Word, result: Sentence)-> Bool{
        let forcedReplacement = getCorrectForm(wordName: word.getName(), dictionary: splitWords)
        if forcedReplacement != ""{
            addSplitWords(multiWord: forcedReplacement!, result: result)
            return true
        }
        return false
    }
    
    public func forcedShortcutSplitCheck(word: Word, result: Sentence)-> Bool{
        var shortcutRegex : String = "(([1-9][0-9]*)|[0])(([.]|[,])[0-9]*)?(" + shortcuts[0]
        for i in 1..<shortcuts.count{
            shortcutRegex += "|" + shortcuts[i]
        }
        shortcutRegex += ")"
        let range1 = NSRange(location: 0, length: word.getName().utf16.count)
        let regex1 = try! NSRegularExpression(pattern: shortcutRegex)
        var conditionalShortcutRegex : String = "(([1-9][0-9]{0,2})|[0])(([.]|[,])[0-9]*)?(" + conditionalShortcuts[0]
        for i in 1..<conditionalShortcuts.count{
            conditionalShortcutRegex += "|" + conditionalShortcuts[i]
        }
        conditionalShortcutRegex += ")"
        let range2 = NSRange(location: 0, length: word.getName().utf16.count)
        let regex2 = try! NSRegularExpression(pattern: conditionalShortcutRegex)
        if regex1.firstMatch(in: word.getName(), options: [], range: range1) != nil || regex2.firstMatch(in: word.getName(), options: [], range: range2) != nil{
            let pair = getSplitPair(word: word)
            result.addWord(word: Word(name: pair.0))
            result.addWord(word: Word(name: pair.1))
            return true
        }
        return false
    }
    
    public func forcedDeDaSplitCheck(word: Word, result: Sentence)-> Bool{
        let wordName = word.getName()
        let capitalizedWordName = Word.toCapital(s: wordName)
        var txtWord : TxtWord? = nil
        if wordName.hasSuffix("da") || wordName.hasSuffix("de") {
            if fsm.morphologicalAnalysis(surfaceForm: wordName).size() == 0 && fsm.morphologicalAnalysis(surfaceForm: capitalizedWordName).size() == 0 {
                let newWordName = String(wordName[..<wordName.index(wordName.startIndex, offsetBy: wordName.count - 2)])
                let fsmParseList = fsm.morphologicalAnalysis(surfaceForm: newWordName)
                let txtNewWord = fsm.getDictionary().getWord(name: Word.lowercase(s: newWordName)) as? TxtWord
                if (txtNewWord != nil && txtNewWord!.isProperNoun()) {
                    if (fsm.morphologicalAnalysis(surfaceForm: newWordName + "'" + "da").size() > 0) {
                        result.addWord(word: Word(name: newWordName + "'" + "da"))
                    }
                    else {
                        result.addWord(word: Word(name: newWordName + "'" + "de"))
                    }
                    return true
                }
                if fsmParseList.size() > 0 {
                    txtWord = fsm.getDictionary().getWord(name: fsmParseList.getParseWithLongestRootWord().getWord().getName()) as? TxtWord
                }
                if (txtWord != nil && !txtWord!.isCode()) {
                    result.addWord(word: Word(name: newWordName))
                    if (TurkishLanguage.isBackVowel(ch: Word.lastVowel(stem: newWordName))) {
                        if (txtWord!.notObeysVowelHarmonyDuringAgglutination()) {
                            result.addWord(word: Word(name: "de"))
                        }
                        else {
                            result.addWord(word: Word(name: "da"))
                        }
                    } else if (txtWord!.notObeysVowelHarmonyDuringAgglutination()) {
                        result.addWord(word: Word(name: "da"))
                    }
                    else {
                        result.addWord(word: Word(name: "de"))
                    }
                    return true
                }
            }
        }
        return false
    }
    
    public func forcedSuffixMergeCheck(word: Word, result: Sentence, previousWord: Word?)-> Bool{
        let liList = ["li", "lı", "lu", "lü"]
        let likList = ["lik", "lık", "luk", "lük"]
        if liList.contains(word.getName()) || likList.contains(word.getName()) {
            let range1 = NSRange(location: 0, length: previousWord!.getName().utf16.count)
            let regex1 = try! NSRegularExpression(pattern: "[0-9]+")
            if previousWord != nil && regex1.firstMatch(in: previousWord!.getName(), options: [], range: range1) != nil {
                for suffix in liList {
                    if word.getName().count == 2 && fsm.morphologicalAnalysis(surfaceForm: previousWord!.getName() + "'" + suffix).size() > 0 {
                        result.replaceWord(i: result.wordCount() - 1, newWord: Word(name: previousWord!.getName() + "'" + suffix))
                        return true
                    }
                }
                for suffix in likList {
                    if word.getName().count == 3 && fsm.morphologicalAnalysis(surfaceForm: previousWord!.getName() + "'" + suffix).size() > 0 {
                        result.replaceWord(i: result.wordCount() - 1, newWord: Word(name: previousWord!.getName() + "'" + suffix))
                        return true
                    }
                }
            }
        }
        return false
    }
    
    public func forcedHyphenMergeCheck(word: Word, result: Sentence, previousWord: Word?, nextWord: Word?) -> Bool{
        if word.getName() == "-" || word.getName() == "–" || word.getName() == "—" {
            let range1 = NSRange(location: 0, length: previousWord!.getName().utf16.count)
            let range2 = NSRange(location: 0, length: nextWord!.getName().utf16.count)
            let regex1 = try! NSRegularExpression(pattern: "[a-zA-ZçöğüşıÇÖĞÜŞİ]+")
            if previousWord != nil && nextWord != nil && regex1.firstMatch(in: previousWord!.getName(), options: [], range: range1) != nil && regex1.firstMatch(in: nextWord!.getName(), options: [], range: range2) != nil {
                let newWordName = previousWord!.getName() + "-" + nextWord!.getName()
                if (fsm.morphologicalAnalysis(surfaceForm: newWordName).size() > 0) {
                    result.replaceWord(i: result.wordCount() - 1, newWord: Word(name: newWordName))
                    return true
                }
            }
        }
        return false
    }
    
    public func forcedQuestionSuffixSplitCheck(word: Word, result: Sentence) -> Bool{
        let wordName = word.getName()
        if (fsm.morphologicalAnalysis(surfaceForm: wordName).size() > 0) {
            return false;
        }
        for questionSuffix in questionSuffixList {
            if wordName.hasSuffix(questionSuffix) {
                let newWordName = String(wordName[..<wordName.index(wordName.endIndex, offsetBy: -questionSuffix.count)])
                let txtWord = fsm.getDictionary().getWord(name: newWordName) as? TxtWord
                if fsm.morphologicalAnalysis(surfaceForm: newWordName).size() > 0 && txtWord != nil && !txtWord!.isCode() {
                    result.addWord(word: Word(name: newWordName))
                    result.addWord(word: Word(name: questionSuffix))
                    return true
                }
            }
        }
        return false
    }
    
    public func mergedCandidatesList(previousWord: Word?, word: Word, nextWord: Word?)->[Candidate]{
        var mergedCandidates : [Candidate] = []
        var backwardMergeCandidate : Candidate? = nil
        var forwardMergeCandidate : Candidate
        if previousWord != nil{
            backwardMergeCandidate = Candidate(candidate: previousWord!.getName() + word.getName(), _operator: Operator.BACKWARD_MERGE)
            let fsmParseList = fsm.morphologicalAnalysis(surfaceForm: backwardMergeCandidate!.getName())
            if fsmParseList.size() != 0{
                mergedCandidates.append(backwardMergeCandidate!)
            }
        }
        if nextWord != nil{
            forwardMergeCandidate = Candidate(candidate: word.getName() + nextWord!.getName(), _operator: Operator.FORWARD_MERGE);
            if backwardMergeCandidate == nil || backwardMergeCandidate!.getName() != forwardMergeCandidate.getName(){
                let fsmParseList = fsm.morphologicalAnalysis(surfaceForm: forwardMergeCandidate.getName());
                if (fsmParseList.size() != 0){
                    mergedCandidates.append(forwardMergeCandidate)
                }
            }
        }
        return mergedCandidates
    }
    
    public func splitCandidatesList(word: Word) -> [Candidate]{
        var splitCandidates : [Candidate] = []
        for i in 4..<word.getName().count - 3 {
            let firstPart = word.getName().prefix(i)
            let secondPart = word.getName().suffix(word.getName().count - i)
            let fsmParseListFirst = fsm.morphologicalAnalysis(surfaceForm: String(firstPart))
            let fsmParseListSecond = fsm.morphologicalAnalysis(surfaceForm: String(secondPart))
            if fsmParseListFirst.size() > 0 && fsmParseListSecond.size() > 0{
                splitCandidates.append(Candidate(candidate: firstPart + " " + secondPart, _operator: Operator.SPLIT))
            }
        }
        return splitCandidates
    }
    
    public func getCorrectForm(wordName: String, dictionary: [String : String]) -> String?{
        if dictionary[wordName] != nil{
            return dictionary[wordName]
        }
        return ""
    }
    
    private func getSplitPair(word: Word) -> (String, String){
        var key : String = ""
        var j : Int = 0
        while j < word.getName().count{
            if Word.charAt(s: word.getName(), i: j) >= "0" && Word.charAt(s: word.getName(), i: j) <= "9" {
                key = key + String(Word.charAt(s: word.getName(), i: j))
            } else {
                break
            }
            j = j + 1
        }
        let value = String(word.getName().suffix(word.getName().count - j))
        return (key, value)
    }
    
    private func loadDictionaries(){
        var myUrl = Bundle.module.url(forResource: "merged", withExtension: "txt")
        do{
            let fileContent = try String(contentsOf: myUrl!, encoding: .utf8)
            let lines : [String] = fileContent.split(whereSeparator: \.isNewline).map(String.init)
            for line in lines{
                let list : [String] = line.split(separator: " ").map(String.init)
                self.mergedWords[list[0] + " " + list[1]] = list[2]
            }
        }catch{
        }
        myUrl = Bundle.module.url(forResource: "split", withExtension: "txt")
        do{
            let fileContent = try String(contentsOf: myUrl!, encoding: .utf8)
            let lines : [String] = fileContent.split(whereSeparator: \.isNewline).map(String.init)
            for line in lines{
                let list : [String] = line.split(separator: " ").map(String.init)
                var result : String = list[1]
                for i in 2..<list.count{
                    result = result + " " + list[i]
                }
                self.splitWords[list[0]] = result
            }
        }catch{
        }
    }
    
}
