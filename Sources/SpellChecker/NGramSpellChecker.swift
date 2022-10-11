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
    private func checkAnalysisAndSetRootForWordAtIndex(sentence: Sentence, index: Int) -> Word?{
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
    
    private func checkAnalysisAndSetRoot(word: String)-> Word?{
        let fsmParses = fsm.morphologicalAnalysis(surfaceForm: word)
        if fsmParses.size() != 0{
            if rootNGram{
                return fsmParses.getParseWithLongestRootWord().getWord()
            } else {
                return Word(name: word)
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
        var root : Word? = checkAnalysisAndSetRootForWordAtIndex(sentence: sentence, index: 0)
        var previousRoot : Word? = nil
        var nextRoot = checkAnalysisAndSetRootForWordAtIndex(sentence: sentence, index: 1)
        var previousProbability, nextProbability: Double
        var i : Int = 0
        while i < sentence.wordCount() {
            var nextWord : Word? = nil
            var previousWord : Word? = nil
            var nextNextWord : Word? = nil
            var previousPreviousWord : Word? = nil
            let word = sentence.getWord(index: i)
            if i > 0{
                previousWord = sentence.getWord(index: i - 1)
            }
            if i > 1{
                previousPreviousWord = sentence.getWord(index: i - 2)
            }
            if i < sentence.wordCount() - 1{
                nextWord = sentence.getWord(index: i + 1)
            }
            if i < sentence.wordCount() - 2{
                nextNextWord = sentence.getWord(index: i + 2)
            }
            if forcedMisspellCheck(word: word, result: result){
                previousRoot = checkAnalysisAndSetRootForWordAtIndex(sentence: result, index: result.wordCount() - 1)
                root = nextRoot
                nextRoot = checkAnalysisAndSetRootForWordAtIndex(sentence: sentence, index: i + 2)
                i = i + 1
                continue
            }
            if  forcedBackwardMergeCheck(word: word, result: result, previousWord: previousWord){
                previousRoot = checkAnalysisAndSetRootForWordAtIndex(sentence: result, index: result.wordCount() - 1)
                root = checkAnalysisAndSetRootForWordAtIndex(sentence: sentence, index: i + 1)
                nextRoot = checkAnalysisAndSetRootForWordAtIndex(sentence: sentence, index: i + 2)
                i = i + 1
                continue
            }
            if forcedForwardMergeCheck(word: word, result: result, nextWord: nextWord){
                i = i + 1
                previousRoot = self.checkAnalysisAndSetRootForWordAtIndex(sentence: result, index: result.wordCount() - 1)
                root = self.checkAnalysisAndSetRootForWordAtIndex(sentence: sentence, index: i + 1)
                nextRoot = self.checkAnalysisAndSetRootForWordAtIndex(sentence: sentence, index: i + 2)
                i = i + 1
                continue
            }
            if forcedSplitCheck(word: word, result: result) || forcedShortcutCheck(word: word, result: result){
                previousRoot = self.checkAnalysisAndSetRootForWordAtIndex(sentence: result, index: result.wordCount() - 1)
                root = nextRoot
                nextRoot = self.checkAnalysisAndSetRootForWordAtIndex(sentence: sentence, index: i + 2)
                i = i + 1
                continue
            }
            if root == nil{
                var candidates : [Candidate] = candidateList(word: word)
                candidates.append(contentsOf: mergedCandidatesList(previousWord: previousWord, word: word, nextWord: nextWord))
                candidates.append(contentsOf: splitCandidatesList(word: word))
                var bestCandidate : Candidate = Candidate(candidate: word.getName(), _operator: Operator.NO_CHANGE)
                var bestRoot : Word = word
                var bestProbability : Double = threshold
                for candidate in candidates {
                    if candidate.getOperator() == Operator.SPELL_CHECK || candidate.getOperator() == Operator.MISSPELLED_REPLACE{
                        root = checkAnalysisAndSetRoot(word: candidate.getName())
                    }
                    if candidate.getOperator() == Operator.BACKWARD_MERGE && previousWord != nil {
                        root = checkAnalysisAndSetRoot(word: previousWord!.getName() + word.getName())
                        if previousPreviousWord != nil{
                            previousRoot = checkAnalysisAndSetRoot(word: previousPreviousWord!.getName())
                        }
                    }
                    if candidate.getOperator() == Operator.FORWARD_MERGE && nextWord != nil {
                        root = checkAnalysisAndSetRoot(word: word.getName() + nextWord!.getName())
                        if nextNextWord != nil {
                            nextRoot = checkAnalysisAndSetRoot(word: nextNextWord!.getName())
                        }
                    }
                    if previousRoot != nil {
                        if (candidate.getOperator() == Operator.SPLIT){
                            root = checkAnalysisAndSetRoot(word: candidate.getName().split(separator: " ").map(String.init)[0])
                        }
                        previousProbability = getProbability(word1: previousRoot!.getName(), word2: root!.getName())
                    } else {
                        previousProbability = 0.0
                    }
                    if nextRoot != nil {
                        if (candidate.getOperator() == Operator.SPLIT){
                            root = checkAnalysisAndSetRoot(word: candidate.getName().split(separator: " ").map(String.init)[1])
                        }
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
                if bestCandidate.getOperator() == Operator.FORWARD_MERGE {
                    i = i + 1
                }
                if bestCandidate.getOperator() == Operator.BACKWARD_MERGE {
                    result.replaceWord(i: i - 1, newWord: Word(name: bestCandidate.getName()))
                } else{
                    if bestCandidate.getOperator() == Operator.SPLIT{
                        addSplitWords(multiWord: bestCandidate.getName(), result: result)
                    } else {
                        result.addWord(word: Word(name: bestCandidate.getName()))
                    }
                }
                root = bestRoot
            } else {
                result.addWord(word: word)
            }
            previousRoot = root
            root = nextRoot!
            nextRoot = checkAnalysisAndSetRootForWordAtIndex(sentence: sentence, index: i + 2)
            i = i + 1
        }
        return result
    }

}
