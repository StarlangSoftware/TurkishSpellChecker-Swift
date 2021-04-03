//
//  File.swift
//
//
//  Created by Olcay Taner YILDIZ on 31.03.2021.
//

import Foundation
import Corpus

protocol SpellChecker {
    
    /**
     * The spellCheck method which takes a {@link Sentence} as an input.
     - Parameters:
        - sentence: {@link Sentence} type input.
     - Returns: Sentence result.
     */
    func spellCheck(sentence: Sentence)->Sentence

}
