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
    case win
    case restart
    case quit
}

struct Game : Codable {
    
    let created : Double
    let state : GameState
    let player1 : Player
    let player2 : Player
    let lastMove : Move
    let gameMoves : [Move]
    
    enum CodingKeys: String, CodingKey {
        case created
        case state
        case player1
        case player2
        case lastMove
        case gameMoves
    }
    
    func getTotalWalls() -> [Wall] {
        return player1.walls + player2.walls
    }
    
}

