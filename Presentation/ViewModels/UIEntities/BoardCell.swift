//
//  BoardCell.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 14/12/22.
//

import Foundation
enum BorderType {
    case wall
    case empty
    case boardBorder
}

enum BoardContentType {
    case empty
    case allowed
    case playerPawn
    case opponentPawn
}
struct BoardCell {
    var index : Int
    var topBorder : BorderType
    var leftBorder : BorderType
    var rightBorder : BorderType
    var bottomBorder : BorderType
    var contentType : BoardContentType
}
