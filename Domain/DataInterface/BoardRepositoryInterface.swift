//
//  BoardRepositoryInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

protocol BoardRepositoryInterface {
    func movePawnOnTheBoard(pawn : Pawn)
    func insertWallOnTheBoard(wall : Wall)
    func getBoardState() -> Board
    func validateMovePawn(pawn : Pawn) -> BoardConflict
    func validateInsertWall(wall : Wall) -> BoardConflict
}
