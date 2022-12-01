//
//  Game.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
enum GameState : String, Codable {
    case inProgress
    case waiting
    case terminated
}

struct Game : Codable, DictionaryConverter {
    
    let created : Double
    let state : GameState
    let player1 : Player
    let player2 : Player
    let board : Board
    let lastMove : Move
    let gameMoves : [Move]
    
    static var defaultValue : Game {
        return Game(created: 0,
                    state: .terminated,
                    player1: Player.defaultValue,
                    player2: Player.defaultValue,
                    board: Board.defaultValue,
                    lastMove: Move.defaultValue,
                    gameMoves: [])
    }
    
    enum CodingKeys: String, CodingKey {
        case created
        case state
        case player1
        case player2
        case board
        case lastMove
        case gameMoves
    }
    
    
}

