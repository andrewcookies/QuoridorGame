//
//  MatchMakingUseCaseProtocol.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation

protocol MatchMakingUseCaseProtocol {
    func searchMatch() async -> String
    func createMatch() async -> Game
    func joinMatch(gameId : String) async -> Game
}
