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
    func validateMovePawn(pawn: Pawn) -> GameEvent {
        let game = readerInterface?.getCurrentGame()
        //TODO: check pawn move and if the game is over (win or lost)
        return .noEvent
    }
    
    func validateInsertWall(wall: Wall) -> GameEvent {
        let game = readerInterface?.getCurrentGame()
        //TODO: check wall move and if the game is over (win or lost)
        return .noEvent
    }

}
