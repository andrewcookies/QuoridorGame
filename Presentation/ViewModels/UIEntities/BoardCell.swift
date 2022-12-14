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

enum ContentType {
    case empty
    case allowed
    case playerPawn
    case opponentPawn
}
struct BoardCell {
    let index : Int
    let topBorder : BorderType
    let leftBorder : BorderType
    let rightBorder : BorderType
    let bottomBorder : BorderType
    let contentType : ContentType
}
