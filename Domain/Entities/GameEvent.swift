//
//  GameEvent.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 06/12/22.
//

import Foundation
enum GameEvent : Error {
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
    case searchingOpponents
    case joiningMatch
    case endGame
}
