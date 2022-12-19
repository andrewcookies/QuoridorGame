//
//  MatchMakingUseCaseProtocol.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation
enum MatchMakingError : Error {
    case matchNotFound
    case APIError
    case noError
}
protocol MatchMakingUseCaseProtocol {
    func searchMatch() async -> Result<String,MatchMakingError>
    func createMatch() async -> Result<Game,MatchMakingError>
    func joinMatch(gameId : String) async -> Result<Game,MatchMakingError>
}
