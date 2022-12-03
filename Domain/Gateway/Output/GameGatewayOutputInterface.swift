//
//  GameGatewayOutputInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation

protocol GameGatewayOutputInterface {
    func updatePawn(pawn: Pawn) async throws
    func updateWall(wall: Wall) async throws
}
