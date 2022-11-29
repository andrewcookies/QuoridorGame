//
//  BoardRepositoryInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

protocol BoardRepositoryInterface {
    func movePawnOnTheBoard(board : Board)
    func insertWallOnTheBoard(board : Board)
    func getBoardState() -> Board
}
