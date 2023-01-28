//
//  Board.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 14/12/22.
//

import Foundation
enum DrawMode {
    case normal
    case reverse
}

struct Board {
    var cells : [[BoardCell]]
    var playerName : String
    var playerId : String
    var playerWalls : Int
    var playerPosition : Int
    
    var opponentName : String
    var opponentId : String
    var opponentWalls : Int
    var opponentPosition : Int
    
    let drawMode : DrawMode
}
