//
//  Validator.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class Validator{}

extension Validator : ValidatorInterface {
    func validatePawnMove(pawn: Pawn, board: Board) -> [BoardConflict] {
        return [.noConflicts]
    }
    
    func validateInsertWall(wall: Wall, board: Board) -> [BoardConflict] {
        return [.noConflicts]
    }
}
