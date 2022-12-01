//
//  Move.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation

struct Move : Codable, DictionaryConverter {
    let player : Player
    let pawnMove : Pawn
    let wallMove : Wall
    
    static var defaultValue : Move {
        return Move(player: Player.defaultValue, pawnMove: Pawn.defaultValue, wallMove: Wall.defaultValue)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case player
        case pawnMove
        case wallMove
    }

}
