//
//  DemoGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 13/12/22.
//

import Foundation

final class DemoGameRepository : GameRepositoryInputInterface, GameRepositoryOutputInterface {
    
    private var inputUseCase : GameInputUseCaseProtocol
    private var demoGame = Game.defaultValue
    
    func createMatch(game: Game) async throws -> Game {
        throw MatchMakingError.APIError
    }
    
    init(inputUseCase : GameInputUseCaseProtocol){
        self.inputUseCase = inputUseCase
    }
    
    func searchMatch(player: Player) async throws {
        throw MatchMakingError.APIError
    }
    
    func updateState(state: GameState) async throws {
        let game = Game(created: demoGame.created,
                        state: state,
                        player1: demoGame.player1,
                        player2: demoGame.player2,
                        lastMove: demoGame.lastMove,
                        gameMoves: demoGame.gameMoves)
        demoGame = game
        inputUseCase.updateGameFromOpponent(game: game)
    }
    
    func updateGame(game: Game) async throws {
        demoGame = game
        inputUseCase.updateGameFromOpponent(game: game)
    }
    
    
    func searchOpenMatch() async throws -> String {
        return "DEMO_ID"
    }
    
    func joinMatch(player: Player, gameId: String) async throws -> Game {
        return demoGame
    }
    
}
