//
//  BoardRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class DataBaseRepository {
    
    private var currentGame : Game
    
    init() {
        self.currentGame = Game.defaultValue
    }
    
}

extension DataBaseRepository : GameRepositoryWriteInterface {
    func movePawnOnTheBoard(pawn: Pawn) {
        //TODO
    }
    
    func insertWallOnTheBoard(wall: Wall) {
        //TODO
    }
    
    func updateGame(game: Game) {
        currentGame = game
    }
    
}

extension DataBaseRepository : GameRepositoryReadInterface {
    func getCurrentGame() -> Game {
        return currentGame
    }
    

}
