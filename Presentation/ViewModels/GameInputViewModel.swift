//
//  MatchmakingViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 04/12/22.
//

import Foundation
import Combine

protocol GameInputViewModelProtocol {
    var gameEventListener : Published<Game>.Publisher { get }
}


final class GameInputViewModel {
    @Published private var currentGame : Game = Game.defaultValue

}

extension GameInputViewModel : PresentationLayerInputListenerInterface {
    func opponentRequestRestartGame(game: Game) {
        //TODO: handle
    }
    
    func opponentQuitMatch(game: Game) {
        //TODO: handle
    }
    
    func opponentWonMatch(game: Game) {
        //TODO: handle
    }
    
    func opponentMadeMove(game: Game) {
        //TODO: handle
    }
    
}

extension GameInputViewModel : GameInputViewModelProtocol {
    var gameEventListener: Published<Game>.Publisher {
        $currentGame
    }
}
