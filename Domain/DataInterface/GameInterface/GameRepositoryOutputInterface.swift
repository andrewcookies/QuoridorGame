//
//  GameInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

protocol GameRepositoryOutputInterface {
    func updateState(state : GameState) async throws
    func updateGame(game : Game) async throws
}

