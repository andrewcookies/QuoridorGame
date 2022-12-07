//
//  GameInputUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 07/12/22.
//

import Foundation

class GameInputUseCase {
    
    private var viewModelListener : PresentationLayerInputListenerInterface?
    
    init(viewModelListener: PresentationLayerInputListenerInterface) {
        self.viewModelListener = viewModelListener
    }
}

extension GameInputUseCase : GameInputUseCaseProtocol {
    func updateGameFromOpponent(game: Game) {
        let state = game.state
        switch state {
        case .inProgress, .waiting:
            viewModelListener?.opponentMadeMove(game: game)
        case .win:
            viewModelListener?.opponentWonMatch(game: game)
        case .restart:
            viewModelListener?.opponentRequestRestartGame(game: game)
        case .quit:
            viewModelListener?.opponentQuitMatch(game: game)
        }
    }
}
