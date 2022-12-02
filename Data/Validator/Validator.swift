//
//  Validator.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class Validator{
    
    private let readerInterface : GameRepositoryReadInterface?
    
    init(readerInterface: GameRepositoryReadInterface?) {
        self.readerInterface = readerInterface
    }
    
}

extension Validator : ValidatorInterface {
    func validateMovePawn(pawn: Pawn) -> [BoardConflict] {
        let game = readerInterface?.getCurrentGame()
        //TODO:
        return [.noConflicts]
    }
    
    func validateInsertWall(wall: Wall) -> [BoardConflict] {
        let game = readerInterface?.getCurrentGame()
        //TODO:
        return [.noConflicts]
    }
}
