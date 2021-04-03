//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.04.2021.
//

import Foundation
import NGram
import MorphologicalAnalysis
import Corpus
import Dictionary

public class NGramSpellChecker : SimpleSpellChecker{
    
    private var nGram : NGram<String>
    private var rootNGram: Bool = true
    private var threshold: Double = 0.0

    /**
     * A constructor of {@link NGramSpellChecker} class which takes a {@link FsmMorphologicalAnalyzer} and an {@link NGram}
     * as inputs. Then, calls its super class {@link SimpleSpellChecker} with given {@link FsmMorphologicalAnalyzer} and
     * assigns given {@link NGram} to the nGram variable.
     - Parameters:
        - fsm:   {@link FsmMorphologicalAnalyzer} type input.
        - nGram: {@link NGram} type input.
        - rootNGram: This parameter must be true, if the nGram is NGram generated from the root words; false otherwise.
     */
    public init(fsm: FsmMorphologicalAnalyzer, nGram: NGram<String>, rootNGram: Bool){
        self.nGram = nGram
        self.rootNGram = rootNGram
        super.init(fsm: fsm)
    }

    /**
     * Checks the morphological analysis of the given word in the given index. If there is no misspelling, it returns
     * the longest root word of the possible analyses.
     - Parameters:
        - sentence: Sentence to be analyzed.
        - index: Index of the word
     - Returns: If the word is misspelled, null; otherwise the longest root word of the possible analyses.
     */
    private func checkAnalysisAndSetRoot(sentence: Sentence, index: Int) -> Word?{
        if index < sentence.wordCount() {
            let fsmParses = fsm.morphologicalAnalysis(surfaceForm: sentence.getWord(index: index).getName())
            if fsmParses.size() != 0 {
                if rootNGram{
                    return fsmParses.getParseWithLongestRootWord().getWord()
                } else {
                    return sentence.getWord(index: index)
                }
            }
        }
        return nil
    }
    
    public func setThreshold(threshold: Double){
        self.threshold = threshold
    }
    
    private func getProbability(word1: String, word2: String) -> Double{
        return nGram.getProbability(word1, word2)
    }

    /**
     * The spellCheck method takes a {@link Sentence} as an input and loops i times where i ranges from 0 to size of words in given sentence.
     * Then, it calls morphologicalAnalysis method with each word and assigns it to the {@link FsmParseList}, if the size of
     * {@link FsmParseList} is equal to the 0, it adds current word to the candidateList and assigns it to the candidates {@link ArrayList}.
     * <p>
     * Later on, it loops through candidates {@link ArrayList} and calls morphologicalAnalysis method with each word and
     * assigns it to the {@link FsmParseList}. Then, it gets the root from {@link FsmParseList}. For the first time, it defines a previousRoot
     * by calling getProbability method with root, and for the following times it calls getProbability method with previousRoot and root.
     * Then, it finds out the best probability and the corresponding candidate as best candidate and adds it to the result {@link Sentence}.
     * <p>
     * If the size of {@link FsmParseList} is not equal to 0, it directly adds the current word to the result {@link Sentence} and finds
     * the previousRoot directly from the {@link FsmParseList}.
     - Parameters:
        - sentence: {@link Sentence} type input.
     - Returns: Sentence result.
     */
    public override func spellCheck(sentence: Sentence) -> Sentence {
        let result : Sentence = Sentence()
        var root : Word? = checkAnalysisAndSetRoot(sentence: sentence, index: 0)
        var previousRoot : Word? = nil
        var nextRoot = checkAnalysisAndSetRoot(sentence: sentence, index: 1)
        var previousProbability, nextProbability: Double
        for i in 0..<sentence.wordCount() {
            let word = sentence.getWord(index: i)
            if root == nil{
                let candidates = candidateList(word: word)
                var bestCandidate : String = word.getName()
                var bestRoot : Word = word
                var bestProbability : Double = threshold
                for candidate in candidates {
                    let fsmParses = fsm.morphologicalAnalysis(surfaceForm: candidate)
                    if rootNGram {
                        root = fsmParses.getParseWithLongestRootWord().getWord()
                    } else {
                        root = Word(name: candidate)
                    }
                    if previousRoot != nil {
                        previousProbability = getProbability(word1: previousRoot!.getName(), word2: root!.getName())
                    } else {
                        previousProbability = 0.0
                    }
                    if nextRoot != nil {
                        nextProbability = getProbability(word1: root!.getName(), word2: nextRoot!.getName())
                    } else {
                        nextProbability = 0.0
                    }
                    if max(previousProbability, nextProbability) > bestProbability {
                        bestCandidate = candidate
                        bestRoot = root!
                        bestProbability = max(previousProbability, nextProbability)
                    }
                }
                root = bestRoot
                result.addWord(word: Word(name: bestCandidate))
            } else {
                result.addWord(word: word)
            }
            previousRoot = root
            root = nextRoot!
            nextRoot = checkAnalysisAndSetRoot(sentence: sentence, index: i + 2)
        }
        return result
    }

}
