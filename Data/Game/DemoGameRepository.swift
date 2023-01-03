//
//  DemoGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 13/12/22.
//

import Foundation

class DemoGameOutputRepository : GameRepositoryOutputInterface {
    
    var demoGame : Game?
    func updateState(state: GameState) async throws {
        if let g = demoGame {
            let game = Game(created: g.created,
                            state: state,
                            player1: g.player1,
                            player2: g.player2,
                            lastMove: g.lastMove,
                            gameMoves: g.gameMoves)
            demoGame = g
            NotificationCenter.default.post(name: Notification.Name("update"), object: nil)
        }
    }
    
    func updateGame(game: Game) async throws {
        if let g = demoGame {
            let demoMove = Move(playerId: "DEMO_PLAYER", pawnMove: Pawn.startValue, wallMove:  Wall.initValue, moveType: .movePawn)
            var moves = g.gameMoves
            moves.append(demoMove)
            let newGame = Game(created: g.created,
                               state: .inProgress,
                               player1: g.player1,
                               player2: g.player2,
                               lastMove: demoMove,
                               gameMoves: moves)
            demoGame = newGame
            NotificationCenter.default.post(name: Notification.Name("update"), object: nil)
        }
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
        if let g = demoGame {
            inputUseCase.updateGameFromOpponent(game: g)
        }
    }
    
    func searchOpenMatch() async throws -> String {
        return "DEMO_ID"
       // throws MatchMakingError.notfou
    }
    
    func joinMatch(player: Player, gameId: String) async throws -> Game {
        guard let g = demoGame else { throw APIError.currentInfoNIL }
        let demoMove = Move(playerId: "DEMO_PLAYER", pawnMove: Pawn.startValue, wallMove:  Wall.initValue, moveType: .movePawn)
        let move = Move(playerId: player.playerId, pawnMove: player.pawnPosition, wallMove: player.walls.last ?? Wall.initValue, moveType: .movePawn)
        var moves = g.gameMoves
        moves.append(demoMove)
        moves.append(move)
        let newGame = Game(created: g.created,
                           state: .inProgress,
                           player1: g.player1,
                           player2: player,
                           lastMove: move,
                           gameMoves: moves)
        demoGame = newGame
        return newGame
    }
    
    func createMatch(game: Game) async throws -> Game {
        throw MatchMakingError.APIError
    }
}
