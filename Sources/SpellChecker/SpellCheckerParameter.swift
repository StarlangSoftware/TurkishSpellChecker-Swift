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
    
    public init(){
    }
    
    public func setThreshold(threshold: Double){
        self.threshold = threshold
    }

    public func setDeMiCheck(deMiCheck: Bool){
        self.deMiCheck = deMiCheck
    }
    
    public func setRootNGram(rootNGram: Bool){
        self.rootNGram = rootNGram
    }
    
    public func getThreshold() -> Double{
        return self.threshold
    }
    
    public func isDeMiCheck() -> Bool{
        return self.deMiCheck
    }
    
    public func isRootNGram() -> Bool{
        return self.rootNGram
    }

}
