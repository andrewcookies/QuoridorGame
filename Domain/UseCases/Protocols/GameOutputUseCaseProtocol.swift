//
//  GameUseCaseProtocol.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation


protocol GameOutputUseCaseProtocol {
    func movePawn(newPawn : Pawn) async -> GameEvent
    func insertWall(wall : Wall) async -> GameEvent
}

