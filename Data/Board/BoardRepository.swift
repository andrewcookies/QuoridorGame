//
//  BoardRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class DataBaseRepository {
    
    private var currentGame : Game
    private var currentGameId : String
    
    init() {
        self.currentGame = Game.defaultValue
        self.currentGameId = "- -"
    }
    
}

extension DataBaseRepository : GameRepositoryWriteInterface {
    func setCurrentGameId(id: String) {
        currentGameId = id
    }
    
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
    func getCurrentGameId() -> String {
        return currentGameId
    }
    
    func getCurrentGame() -> Game {
        return currentGame
    }
}
