//
//  Move.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
enum MoveType : String, Codable {
    case insertWall
    case movePawn
}

struct Move : Codable, DictionaryConverter {
    let playerName : String
    let pawnMove : Pawn
    let wallMove : Wall
    let moveType : MoveType
    
    static var defaultValue : Move {
        return Move(playerName: "- -", pawnMove: Pawn.defaultValue, wallMove: Wall.initValue, moveType: .movePawn)
    }
    
    static var startValue : Move {
        return Move(playerName: "start", pawnMove: Pawn.startValue, wallMove: Wall.initValue, moveType: .movePawn)
    }
    
    enum CodingKeys: String, CodingKey {
        case playerName
        case pawnMove
        case wallMove
        case moveType
    }

}
