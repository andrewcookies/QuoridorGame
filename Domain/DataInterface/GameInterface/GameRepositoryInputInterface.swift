//
//  GameInputInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 05/12/22.
//

import Foundation

protocol GameRepositoryInputInterface {
    func searchMatch(player : Player) async throws -> String
}
