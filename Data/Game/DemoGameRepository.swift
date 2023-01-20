//
//  DemoGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 13/12/22.
//

import Foundation

class DemoGameOutputRepository : GameRepositoryOutputInterface {
    
    var demoGame : Game?
    let defaultWall = Wall(orientation: .horizontal, topLeftCell: -1, topRightCell: -1, bottomLeftCell: -1, bottomRightCell: -1)
    let demoPlayerStartPawn = Pawn(position: 34)

    init() {
        let defaultPlayer1 = Player(name: defaultPlayerName, playerId: defaultPlayerId, pawnPosition: demoPlayerStartPawn, walls: [])
        let defaultPlayer2 = Player(name: defaultPlayerName, playerId: defaultPlayerId, pawnPosition: Pawn(position: startPlayer2PawnPosition), walls: [])
        let defaultWall = Wall(orientation: .horizontal, topLeftCell: -1, topRightCell: -1, bottomLeftCell: -1, bottomRightCell: -1)
        let defaultMove = Move(playerId: defaultPlayerId, pawnMove: Pawn(position: pawnNilMove), wallMove: defaultWall, moveType: .movePawn)

        let game = Game(created: 0, state: .waiting, player1: defaultPlayer1, player2: defaultPlayer2, lastMove: defaultMove, gameMoves: [defaultMove])
        self.demoGame = game
    }
    
    func updateState(state: GameState) async throws {
        if let g = demoGame {
            let game = Game(created: g.created,
                            state: state,
                            player1: g.player1,
                            player2: g.player2,
                            lastMove: g.lastMove,
                            gameMoves: g.gameMoves)
            demoGame = game
        }
    }
    
    func updateGame(game: Game) async throws {
        if let g = demoGame {
            let demoMove = Move(playerId: "DEMO_PLAYER", pawnMove: demoPlayerStartPawn, wallMove:  defaultWall, moveType: .movePawn)
            var moves = g.gameMoves
            moves.append(demoMove)
            let newGame = Game(created: g.created,
                               state: .inProgress,
                               player1: g.player1,
                               player2: g.player2,
                               lastMove: demoMove,
                               gameMoves: moves)
            demoGame = newGame
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
        if let g = self.demoGame {
            self.inputUseCase.updateGameFromOpponent(game: g)
        }
    }
    
    func searchOpenMatch() async throws -> String {
        return "DEMO_ID"
       // throws MatchMakingError.notfou
    }
    
    func joinMatch(player: Player, gameId: String) async throws -> Game {
        guard let g = demoGame else { throw APIError.currentInfoNIL }
        let demoMove = Move(playerId: "DEMO_PLAYER", pawnMove: demoPlayerStartPawn, wallMove:  defaultWall, moveType: .movePawn)
        let move = Move(playerId: player.playerId, pawnMove: player.pawnPosition, wallMove: player.walls.last ?? defaultWall, moveType: .movePawn)
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
