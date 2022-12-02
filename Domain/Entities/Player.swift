//
//  Player.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation

struct Player : Codable, DictionaryConverter {
    let name : String
    let playerId : String
    let pawnPosition : Pawn
    let walls : [Wall]
    
    static var defaultValue : Player {
        return Player(name: "none", playerId: "-1", pawnPosition: Pawn.defaultValue, walls: [])
    }
        
    
    enum CodingKeys: String, CodingKey {
        case name
        case playerId
        case pawnPosition
        case walls
    }
    
}
