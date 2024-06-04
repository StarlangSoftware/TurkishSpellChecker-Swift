//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 2.10.2022.
//

import Foundation
import Dictionary

public class Candidate : Word{
    
    private var _operator: Operator = Operator.NO_CHANGE
    
    /// Constructs a new Candidate object with the specified candidate and operator.
    /// - Parameters:
    ///   - candidate: The word candidate to be checked for spelling.
    ///   - _operator: The operator to be applied to the candidate in the spell checking process.
    public init(candidate: String, _operator: Operator) {
        self._operator = _operator
        super.init(name: candidate)
    }
    
    /// Returns the operator associated with this candidate.
    /// - Returns: The operator associated with this candidate.
    public func getOperator()-> Operator{
        return self._operator
    }
}
