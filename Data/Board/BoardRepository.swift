//
//  BoardRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class BoardRespository {
    
    private var board : Board
    private var validator : ValidatorInterface?
    
    init(validator: ValidatorInterface?) {
        self.board = Board()
        self.validator = validator
    }
    
}

extension BoardRespository : BoardRepositoryInterface {
    func movePawnOnTheBoard(pawn: Pawn) {
        board.userPawn = pawn
    }
    
    func insertWallOnTheBoard(wall: Wall) {
        board.walls.append(wall)
    }
    
    func getBoardState() -> Board {
        return board
    }
    
    func validateMovePawn(pawn: Pawn) -> BoardConflict {
        let conflicts = validator?.validatePawnMove(pawn: pawn, board: board) ?? [.genericError]
        return conflicts.first ?? .genericError
    }
    
    func validateInsertWall(wall: Wall) -> BoardConflict {
        let conflicts = validator?.validateInsertWall(wall: wall, board: board) ?? [.genericError]
        return conflicts.first ?? .genericError
    }
}
