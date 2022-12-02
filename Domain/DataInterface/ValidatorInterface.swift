//
//  ValidatorInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
enum BoardConflict {
    case noConflicts
    case genericError
    case wrongWallPosition
    case noMoreWalls
}

protocol ValidatorInterface {
    func validateMovePawn(pawn : Pawn) -> [BoardConflict]
    func validateInsertWall(wall : Wall) -> [BoardConflict]
}
