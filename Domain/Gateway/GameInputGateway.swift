//
//  GameInputGateway.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation

final class GameInputGateway {
    
    private var dataBaseWriterInterface : GameRepositoryWriteInterface?
    private var controller : PresentationGameListenerInterface?

    
    init(dataBaseWriterInterface: GameRepositoryWriteInterface?,
         controller: PresentationGameListenerInterface?) {
        self.dataBaseWriterInterface = dataBaseWriterInterface
        self.controller = controller
    }
}

extension GameInputGateway : GameGatewayInputInterface {
    func updatedReceived(game: Game) {
        dataBaseWriterInterface?.updateGame(game: game)
        controller?.updatePresentationLayer(game: game)
    }
}

