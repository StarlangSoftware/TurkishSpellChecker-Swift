//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 2.10.2022.
//

import Foundation

public enum Operator : String{
    case NO_CHANGE
    case MISSPELLED_REPLACE
    case FORCED_MERGE
    case FORCED_SPLIT
    case SPLIT_WITH_SHORTCUT
    case SPELL_CHECK
    case SPLIT
    case FORWARD_MERGE
    case BACKWARD_MERGE
}
