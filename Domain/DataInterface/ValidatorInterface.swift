//
//  ValidatorInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

protocol ValidatorInterface {
    func validateMovePawn(pawn : Pawn) -> GameEvent
    func validateInsertWall(wall : Wall) -> GameEvent
}
