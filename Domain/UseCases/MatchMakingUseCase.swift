//
//  MatchMakingUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation

final class MatchMakingUseCase {
    
    private var gameInputInterface : GameRepositoryInputInterface
    private var gameFactory : GameFactoryProtocol
    
    init(gameInputInterface: GameRepositoryInputInterface,
         gameFactory : GameFactoryProtocol) {
        self.gameInputInterface = gameInputInterface
        self.gameFactory = gameFactory
    }
}

extension MatchMakingUseCase : MatchMakingUseCaseProtocol {
    func searchMatch() async -> Result<String,MatchMakingError> {
        do {
            let gameId = try await gameInputInterface.searchOpenMatch()
            return .success(gameId)
        } catch {
            return .failure(.matchNotFound)
        }
    }
    
    func createMatch() async -> Result<Game,MatchMakingError> {
        do {
            let newGame = gameFactory.createGame()
            let game = try await gameInputInterface.createMatch(game: newGame)
            gameFactory.updateGame(game: game)
            return .success(game)
        } catch {
            return .failure(.APIError)
        }
    }
    
    func joinMatch(gameId: String) async -> Result<Game,MatchMakingError> {
        do {
            let player = gameFactory.getPlayerToJoinGame()
            let game = try await gameInputInterface.joinMatch(player: player, gameId: gameId)
            gameFactory.updateGame(game: game)
            return .success(game)
        } catch {
            return .failure(.APIError)
        }
    }
    
}
