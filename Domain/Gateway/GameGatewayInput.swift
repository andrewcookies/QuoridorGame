//
//  GameInputGateway.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation

final class GameGatewayInput {
    
    private var dataBaseWriterInterface : GameRepositoryWriteInterface?
    private var controller : GameInputUseCaseProtocol?

    
    init(dataBaseWriterInterface: GameRepositoryWriteInterface?,
         controller: GameInputUseCaseProtocol?) {
        self.dataBaseWriterInterface = dataBaseWriterInterface
        self.controller = controller
    }
}

extension GameGatewayInput : GameGatewayInputInterface {
    func updatedReceived(game: Game) {
        dataBaseWriterInterface?.updateGame(game: game)
        controller?.updateGameFromOpponent(game: game)
    }
}
