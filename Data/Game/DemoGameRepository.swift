//
//  DemoGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 13/12/22.
//

import Foundation

final class DemoGameRepository : GameRepositoryInputInterface, GameRepositoryOutputInterface {
    
    private var gatewayInputInterface : GameGatewayInputInterface?
    private var demoGame = Game.defaultValue
    
    init(gatewayInputInterface : GameGatewayInputInterface?){
        self.gatewayInputInterface = gatewayInputInterface
    }
    
    func searchMatch(player: Player) async throws {
        gatewayInputInterface?.updatedReceived(game: demoGame)
    }
    
    func updateState(state: GameState) async throws {
        let game = Game(created: demoGame.created,
                        state: state,
                        player1: demoGame.player1,
                        player2: demoGame.player2,
                        lastMove: demoGame.lastMove,
                        gameMoves: demoGame.gameMoves)
        demoGame = game
        gatewayInputInterface?.updatedReceived(game: game)
    }
    
    func updateGame(game: Game) async throws {
        demoGame = game
        gatewayInputInterface?.updatedReceived(game: demoGame)
    }
    
}
