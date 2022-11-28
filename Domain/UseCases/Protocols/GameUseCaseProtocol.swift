//
//  GameUseCaseProtocol.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

protocol GameUseCaseProtocol {
    
    func movePawn(newPawn : Pawn)
    func insertWall(wall : Wall)
    func getBoardState() -> Board
    //add listener
}

