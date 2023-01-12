//
//  GameEvent.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 06/12/22.
//

import Foundation
enum GameEvent : Error {
    case invalidWall

    
    case waiting
    case waitingOpponentMove
    case matchWon
    case matchLost
    case error
    case noWall
    case invalidPawn
    case noEvent
    case searchingOpponents
    case endGame
}
