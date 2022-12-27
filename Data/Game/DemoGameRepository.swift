//
//  DemoGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 13/12/22.
//

import Foundation

class DemoGameOutputRepository : GameRepositoryOutputInterface {
    
    var demoGame = Game.defaultValue
    func updateState(state: GameState) async throws {
        let game = Game(created: demoGame.created,
                        state: state,
                        player1: demoGame.player1,
                        player2: demoGame.player2,
                        lastMove: demoGame.lastMove,
                        gameMoves: demoGame.gameMoves)
        demoGame = game
        NotificationCenter.default.post(name: Notification.Name("update"), object: nil)
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
        NotificationCenter.default.post(name: Notification.Name("update"), object: nil)
    }
    
  
}


class DemoGameInputRepository : DemoGameOutputRepository, GameRepositoryInputInterface{
    
    var inputUseCase : GameInputUseCaseProtocol
    init(inputUseCase : GameInputUseCaseProtocol) {
        self.inputUseCase = inputUseCase
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(update),name: Notification.Name("update"), object: nil)
    }
    
    @objc func update(){
        inputUseCase.updateGameFromOpponent(game: demoGame)
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
    
    func createMatch(game: Game) async throws -> Game {
        throw MatchMakingError.APIError
    }
}
