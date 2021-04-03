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
    
    /**
     * A constructor of {@link SimpleSpellChecker} class which takes a {@link FsmMorphologicalAnalyzer} as an input and
     * assigns it to the fsm variable.
     - Parameters:
        - fsm: {@link FsmMorphologicalAnalyzer} type input.
     */
    public init(fsm: FsmMorphologicalAnalyzer){
        self.fsm = fsm
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
    private func generateCandidateList(word: String) -> [String]{
        let s = TurkishLanguage.LOWERCASE_LETTERS;
        var candidates : [String] = []
        for i in 0..<word.count {
            if i < word.count - 1{
                let swapped = swapChar(word: word, index: i)
                candidates.append(swapped)
            }
            if TurkishLanguage.LETTERS.contains(Word.charAt(s: word, i: i)) || "wxq".contains(Word.charAt(s: word, i: i)){
                let deleted = deleteChar(word: word, index: i)
                candidates.append(deleted)
                for j in 0..<s.count {
                    let replaced = replaceChar(word: word, index: i, char: String(Word.charAt(s: s, i: j)))
                    candidates.append(replaced);
                }
                for j in 0..<s.count {
                    let added = addChar(word: word, index: i, char: String(Word.charAt(s: s, i: j)))
                    candidates.append(added)
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
    public func candidateList(word: Word) -> [String]{
        var candidates: [String] = []
        candidates = generateCandidateList(word: word.getName())
        var i : Int = 0
        while i < candidates.count {
            let fsmParseList = fsm.morphologicalAnalysis(surfaceForm: candidates[i])
            if fsmParseList.size() == 0 {
                let newCandidate = fsm.getDictionary().getCorrectForm(misspelledWord: candidates[i])
                if newCandidate != "" && fsm.morphologicalAnalysis(surfaceForm: newCandidate).size() > 0{
                    candidates[i] = newCandidate
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
        for i in 0..<sentence.wordCount() {
            let word = sentence.getWord(index: i)
            var newWord : Word
            let fsmParseList = fsm.morphologicalAnalysis(surfaceForm: word.getName())
            if fsmParseList.size() == 0{
                let candidates = candidateList(word: word)
                if candidates.count > 0 {
                    newWord = Word(name: candidates[Int.random(in: 0..<candidates.count)])
                } else {
                    newWord = word
                }
            } else {
                newWord = word
            }
            result.addWord(word: newWord)
        }
        return result
    }
    
}
