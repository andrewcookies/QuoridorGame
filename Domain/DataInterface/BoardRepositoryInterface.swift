//
//  BoardRepositoryInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

protocol BoardRepositoryInterface {
    func updateBoard(board : Board)
    func getBoardState() -> Board
}
