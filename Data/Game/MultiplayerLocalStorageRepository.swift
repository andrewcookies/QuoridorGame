//
//  LocalGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class MultiplayerLocalStorageRepository {
    private var gameId : String = ""
}


extension MultiplayerLocalStorageRepository : MultiplayerLocalRepositoryInterface {
    func setCurrentGameId(gameId: String) {
        self.gameId = gameId
    }
    
    func getCurrentGameId() -> String {
        return gameId
    }
}
