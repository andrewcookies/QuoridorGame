//
//  GameInputInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 05/12/22.
//

import Foundation

protocol GameRepositoryInputInterface {
    func searchOpenMatch() async throws -> String
    func createMatch(player : Player) async throws -> Game
    func joinMatch(player: Player, gameId : String) async throws -> Game
}
