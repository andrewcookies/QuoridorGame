//
//  GameInputUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 07/12/22.
//

import Foundation

class GameInputUseCase {
    
    private var viewModelListener : PresentationLayerInputListenerInterface
    private var gameFactory : GameFactoryProtocol
    
    init(viewModelListener : PresentationLayerInputListenerInterface,
         gameFactory : GameFactoryProtocol) {
        self.viewModelListener = viewModelListener
        self.gameFactory = gameFactory
    }
}

extension GameInputUseCase : GameInputUseCaseProtocol {
    func updateGameFromOpponent(game: Game) {
        let state = game.state
        gameFactory.updateGame(game: game)
        GameLog.shared.debug(message: "game update received : \(state.rawValue)", className: "GameInputUseCase")
        switch state {
        case .inProgress, .waiting:
            viewModelListener.opponentMadeMove(game: game)
        case .win:
            viewModelListener.opponentWonMatch(game: game)
        case .restart:
            viewModelListener.opponentRequestRestartGame(game: game)
        case .quit:
            viewModelListener.opponentQuitMatch(game: game)
        }
    }
}
