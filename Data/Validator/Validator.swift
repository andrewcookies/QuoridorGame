//
//  Validator.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class Validator{
    
    private let readerInterface : GameRepositoryReadInterface?
    private let userInterface : UserInfoInterface?
    
    init(readerInterface: GameRepositoryReadInterface?,
         userInterface : UserInfoInterface?) {
        self.readerInterface = readerInterface
        self.userInterface = userInterface
    }
    
}

extension Validator : ValidatorInterface {
    func fetchAllowedPawn() -> [Pawn] {
        let game = readerInterface?.getCurrentGame()
        let player = game?.player1.playerId == userInterface?.getUserInfo().userId ? game?.player1 : game?.player2
        var res = [Int]()
        
        if let p = player  {
            let totalWall = (game?.player1.walls ?? []) + (game?.player2.walls ?? [])
            let currentPosition = p.pawnPosition.position
            
            let northPosition = currentPosition + bufferTopDownCell
            if totalWall.contains(where: { ($0.topLeftCell == northPosition || $0.topRightCell == northPosition) && $0.orientation == .horizontal }) == false {
                if northPosition > 0 && northPosition < 89 {
                    res.append(northPosition)
                }
            }
            
            let southPosition = currentPosition - bufferTopDownCell
            if totalWall.contains(where: { ($0.bottomLeftCell == southPosition || $0.bottomRightCell == southPosition) && $0.orientation == .horizontal }) == false {
                if northPosition > 0 && northPosition < 89 {
                    res.append(southPosition)
                }
            }
            
            let eastPosition = currentPosition - bufferLeftRightCell
            if totalWall.contains(where: { ($0.bottomLeftCell == eastPosition || $0.topLeftCell == southPosition) && $0.orientation == .vertical }) == false {
                if leftRightBorder.contains(eastPosition) == false {
                    res.append(eastPosition)
                }
            }
            
            let westPosition = currentPosition + bufferLeftRightCell
            if totalWall.contains(where: { ($0.bottomRightCell == westPosition || $0.topRightCell == westPosition) && $0.orientation == .vertical }) == false {
                if leftRightBorder.contains(westPosition) == false {
                    res.append(eastPosition)
                }
            }
            
        }
        
        return res.map({ return Pawn(position: $0)})
    }
    
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
