//
//  GameInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

protocol GameInterface {
    func searchMatch() async throws
    func updatePawn(pawn : Pawn) async throws
    func updateWalls(wall : Wall) async throws
    
    var gameListener : Published<Game>.Publisher { get }
}

