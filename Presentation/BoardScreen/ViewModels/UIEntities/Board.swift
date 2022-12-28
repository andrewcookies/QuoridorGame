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
    var player : Player
    var opponent : Player
    let drawMode : DrawMode
}
