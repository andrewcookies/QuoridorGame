//
//  GameUseCaseProtocol.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
import Combine

enum GameEvent {
    case waiting
    case waitingOpponentMove
    case matchWon
    case matchLost
    case updateBoard
    case error
    case invalidWall
    case noWall
    case invalidPawn
    case noEvent
}


protocol GameUseCaseProtocol {
    
    func movePawn(newPawn : Pawn) async -> GameEvent
    func insertWall(wall : Wall) async -> GameEvent
    
    var board : Published<Board>.Publisher { get }
}

