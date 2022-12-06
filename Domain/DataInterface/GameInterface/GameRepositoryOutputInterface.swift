//
//  GameInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
enum PlayerType {
    case player1
    case player2
}

protocol GameRepositoryOutputInterface {
    func sendMove(player : Player, moves : [Move], playerType : PlayerType) async throws
    func updateState(state : GameState) async throws
}

