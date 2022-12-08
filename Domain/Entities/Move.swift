//
//  Move.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation

struct Move : Codable, DictionaryConverter {
    let playerName : String
    let pawnMove : Pawn
    let wallMove : Wall
    
    static var defaultValue : Move {
        return Move(playerName: "- -", pawnMove: Pawn.defaultValue, wallMove: Wall.initValue)
    }
    
    static var startValue : Move {
        return Move(playerName: "start", pawnMove: Pawn.startValue, wallMove: Wall.initValue)
    }
    
    enum CodingKeys: String, CodingKey {
        case playerName
        case pawnMove
        case wallMove
    }

}
