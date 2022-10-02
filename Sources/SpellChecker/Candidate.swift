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
    
    public init(candidate: String, _operator: Operator) {
        self._operator = _operator
        super.init(name: candidate)
    }
    
    public func getOperator()-> Operator{
        return self._operator
    }
}
