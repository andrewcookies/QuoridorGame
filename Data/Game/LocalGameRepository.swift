//
//  LocalGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class LocalGameRepository {
    private var gameId : String = ""
}


extension LocalGameRepository : MultiplayerLocalRepositoryInterface {
    func setCurrentGameId(gameId: String) {
        self.gameId = gameId
    }
    
    func getCurrentGameId() -> String {
        return gameId
    }
}
