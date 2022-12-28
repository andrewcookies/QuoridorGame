//
//  Player.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation

struct Player : Codable {
    let name : String
    let playerId : String
    var pawnPosition : Pawn
    let walls : [Wall]
    
    static var startPlayerValue : Player {
        return Player(name: "-", playerId: "-1", pawnPosition: Pawn.startValue, walls: [])
    }
    
    static var startOpponentValue : Player {
        return Player(name: "-", playerId: "-1", pawnPosition: Pawn.startOppositePlayer, walls: [])
    }
    
        
    
    enum CodingKeys: String, CodingKey {
        case name
        case playerId
        case pawnPosition
        case walls
    }
    
}
