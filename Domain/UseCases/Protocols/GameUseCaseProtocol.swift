//
//  GameUseCaseProtocol.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
import Combine

enum GameEvent {
    case matchWon
    case matchLost
    case updateBoard
    case genericError
    case invalidWall
    case noWall
    case invalidPawn
    case noEvent
}


protocol GameUseCaseProtocol {
    
    func movePawn(newPawn : Pawn)
    func insertWall(wall : Wall)
    func getBoardState() -> Board
    
    var gameEvent : Published<GameEvent>.Publisher { get }
}

