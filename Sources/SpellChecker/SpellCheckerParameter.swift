//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 24.11.2022.
//

import Foundation

public class SpellCheckerParameter{
    
    private var threshold: Double = 0.0
    private var deMiCheck: Bool = true
    private var rootNGram: Bool = true
    
    /// Constructs a SpellCheckerParameter object with default values.
    /// The default threshold is 0.0, the suffix check is enabled, the root ngram is enabled,
    /// the minimum word length is 4 and domain name value is null.
    public init(){
    }
    
    /// Sets the threshold value used in calculating the n-gram probabilities.
    /// - Parameter threshold: the threshold for the spell checker
    public func setThreshold(threshold: Double){
        self.threshold = threshold
    }
    
    /// Mutator for deMiCheck field.
    /// - Parameter deMiCheck: New deMiCheck value
    public func setDeMiCheck(deMiCheck: Bool){
        self.deMiCheck = deMiCheck
    }
    
    /// Enables or disables the root n-gram for the spell checker.
    /// - Parameter rootNGram: a boolean indicating whether the root n-gram should be enabled (true) or disabled (false)
    public func setRootNGram(rootNGram: Bool){
        self.rootNGram = rootNGram
    }
    
    public func getThreshold() -> Double{
        return self.threshold
    }
    
    public func isDeMiCheck() -> Bool{
        return self.deMiCheck
    }
    
    /// Returns whether the root n-gram is enabled for the spell checker.
    /// - Returns: a boolean indicating whether the root n-gram is enabled for the spell checker
    public func isRootNGram() -> Bool{
        return self.rootNGram
    }

}
