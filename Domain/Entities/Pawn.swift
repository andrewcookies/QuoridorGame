//
//  Pawn.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
struct Pawn : Codable, DictionaryConverter {
    let position : Int
    
  
    static var defaultValue : Pawn {
        return Pawn(position: -1)
    }
    
    static var startValue : Pawn {
        return Pawn(position: 4)
    }
    
    static var startOppositePlayer : Pawn {
        return Pawn(position: 84)
    }
    
    enum CodingKeys: String, CodingKey {
        case position
    }
    
    
}
