//
//  BoardRepositoryInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

protocol GameRepositoryWriteInterface {
    func movePawnOnTheBoard(pawn : Pawn)
    func insertWallOnTheBoard(wall : Wall)
    func updateGame(game : Game)
    func setCurrentGameId(id : String)
}

