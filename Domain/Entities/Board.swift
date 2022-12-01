//
//  Board.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

struct Board: Codable, DictionaryConverter {
        
    var player1Pawn : Pawn
    var player1RemaingWalls : Int
    var player2Pawn : Pawn
    var player2RemaingWalls : Int
    var wallsOnBoard : [Wall]
    
    static var defaultValue : Board {
        return Board(player1Pawn: Pawn.defaultValue,
                     player1RemaingWalls: 0,
                     player2Pawn: Pawn.defaultValue,
                     player2RemaingWalls: 0,
                     wallsOnBoard: [])
    }
    
    static var startValue : Board {
        return Board(player1Pawn: Pawn.startValue,
                     player1RemaingWalls: 10,
                     player2Pawn: Pawn.startOppositePlayer,
                     player2RemaingWalls: 10,
                     wallsOnBoard: [])
    }
   
    
    enum CodingKeys: String, CodingKey {
        case player1Pawn
        case player1RemaingWalls
        case player2Pawn
        case player2RemaingWalls
        case wallsOnBoard
    }
    
}

