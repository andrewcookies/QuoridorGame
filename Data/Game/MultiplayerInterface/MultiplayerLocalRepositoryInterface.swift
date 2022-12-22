//
//  File.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 22/12/22.
//

import Foundation

protocol MultiplayerLocalRepositoryInterface {
    func setCurrentGameId(gameId : String)
    func getCurrentGameId() -> String
}

