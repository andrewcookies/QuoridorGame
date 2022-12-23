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
        let demoMove = Move(playerId: "DEMO_PLAYER", pawnMove: Pawn.startValue, wallMove:  Wall.initValue, moveType: .movePawn)
        var moves = demoGame.gameMoves
        moves.append(demoMove)
        let newGame = Game(created: game.created,
                           state: .inProgress,
                           player1: game.player1,
                           player2: game.player2,
                           lastMove: demoMove,
                           gameMoves: moves)
        demoGame = newGame
        inputUseCase.updateGameFromOpponent(game: game)
    }
    
    
    func searchOpenMatch() async throws -> String {
        return "DEMO_ID"
       // throws MatchMakingError.notfou
    }
    
    func joinMatch(player: Player, gameId: String) async throws -> Game {
        
        let demoMove = Move(playerId: "DEMO_PLAYER", pawnMove: Pawn.startValue, wallMove:  Wall.initValue, moveType: .movePawn)
        let move = Move(playerId: player.playerId, pawnMove: player.pawnPosition, wallMove: player.walls.last ?? Wall.initValue, moveType: .movePawn)
        var moves = demoGame.gameMoves
        moves.append(demoMove)
        moves.append(move)
        let newGame = Game(created: demoGame.created,
                           state: .inProgress,
                           player1: demoGame.player1,
                           player2: player,
                           lastMove: move,
                           gameMoves: moves)
        demoGame = newGame
        return demoGame
    }
    
}
