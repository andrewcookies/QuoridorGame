//
//  Wall.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
enum WallOrientation {
    case vertical
    case horizontal
}

enum WallPosition {
    case top
    case bottom
    case middle
    case right
    case left
}

struct Wall {
    let orientation : WallOrientation
    let position : WallPosition
    let topLeftCell : Int
}
