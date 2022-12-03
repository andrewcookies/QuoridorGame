//
//  GameRepositoryReadnterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 02/12/22.
//

import Foundation

protocol GameRepositoryReadInterface {
    func getCurrentGame() -> Game
    func getCurrentGameId() -> String
}
