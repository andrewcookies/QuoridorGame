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
    let cells : [[BoardCell]]
    let player : Player
    let opponent : Player
    let drawMode : DrawMode
}
