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

extension GameInputViewModel : GameInputUseCaseProtocol {
    func updateGameFromOpponent(game: Game) {
        self.currentGame = game
    }
}

extension GameInputViewModel : GameInputViewModelProtocol {
    var gameEventListener: Published<Game>.Publisher {
        $currentGame
    }
}
