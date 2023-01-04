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
    
    var topRightBorder : BorderType
    var topLeftBorder : BorderType

    var bottomLeftBorder : BorderType
    var bottomRightBorder : BorderType

    var rightTopBorder : BorderType
    var rightBottomBorder : BorderType
    
    var leftTopBorder : BorderType
    var leftBottomBorder : BorderType
    
    var contentType : BoardContentType
    
    
    init(){
        index = -1
        
        topRightBorder = .empty
        topLeftBorder = .empty

        bottomLeftBorder = .empty
        bottomRightBorder = .empty

        rightTopBorder = .empty
        rightBottomBorder = .empty
        
        leftTopBorder = .empty
        leftBottomBorder = .empty
        
        contentType = .empty
    }
     
    
    init(index: Int,
         topRightBorder: BorderType,
         topLeftBorder: BorderType,
         bottomLeftBorder: BorderType,
         bottomRightBorder: BorderType,
         rightTopBorder: BorderType,
         rightBottomBorder: BorderType,
         leftTopBorder: BorderType,
         leftBottomBorder: BorderType,
         contentType: BoardContentType) {
        self.index = index
        self.topRightBorder = topRightBorder
        self.topLeftBorder = topLeftBorder
        self.bottomLeftBorder = bottomLeftBorder
        self.bottomRightBorder = bottomRightBorder
        self.rightTopBorder = rightTopBorder
        self.rightBottomBorder = rightBottomBorder
        self.leftTopBorder = leftTopBorder
        self.leftBottomBorder = leftBottomBorder
        self.contentType = contentType
    }
}
