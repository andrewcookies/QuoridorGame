//
//  Pawn.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
struct Pawn : Codable {
    let position : Int
    
  
    static var defaultValue : Pawn {
        return Pawn(position: -1)
    }
    
    static var startValue : Pawn {
        return Pawn(position: startPlayer1PawnPosition)
    }
    
    static var startOppositePlayer : Pawn {
        return Pawn(position: startPlayer1PawnPosition)
    }
    
    enum CodingKeys: String, CodingKey {
        case position
    }
    
    
    static func == (lhs: Pawn, rhs: Pawn) -> Bool {
        return lhs.position == rhs.position
    }
    
    
}
