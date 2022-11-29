//
//  GameUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation
import Combine


final class GameUseCase {
    
    private var validatorInterface : ValidatorInterface?
    private var userInfoInterface : UserInfoInterface?
    private var boardInterface : BoardRepositoryInterface?
    private var gameInterface : GameInterface?
    @Published private var localGameEvent : GameEvent = .noEvent
    
    init(validatorInterface: ValidatorInterface?,
         userInfoInterface: UserInfoInterface?,
         boardInterface: BoardRepositoryInterface?,
         gameInterface: GameInterface?) {
        self.validatorInterface = validatorInterface
        self.userInfoInterface = userInfoInterface
        self.boardInterface = boardInterface
        self.gameInterface = gameInterface
    }
    
    func conflictsToEvent(conflict : BoardConflict) -> GameEvent {
        switch conflict {
            
        case .genericError:
            return .genericError

        case .wrongWallPosition:
            return .invalidWall
        
        case .noMoreWalls:
            return .noWall
            
        default:
            return .genericError
        }
    }
}

extension GameUseCase : GameUseCaseProtocol {
    
    var gameEvent: Published<GameEvent>.Publisher {
        $localGameEvent
    }
    
    func movePawn(newPawn: Pawn) {
        if let board = boardInterface?.getBoardState() {
            let conflicts = validatorInterface?.validatePawnMove(pawn: newPawn, board: board) ?? [.genericError]
            if conflicts.count == 0 {
                boardInterface?.movePawnOnTheBoard(board: board)
              //  gameInterface?
            }
        } else {
            localGameEvent = .genericError
        }
    }
    
    func insertWall(wall: Wall) {
        if let board = boardInterface?.getBoardState() {
            let conflicts = validatorInterface?.validateInsertWall(wall: wall, board: board) ?? [.genericError]
            if conflicts.count == 0 {
                boardInterface?.movePawnOnTheBoard(board: board)
              //  gameInterface?
            } else {
                let event = conflictsToEvent(conflict: conflicts.first ?? .genericError)
                localGameEvent = event
            }
        } else {
            localGameEvent = .genericError
        }
    }
    
    func getBoardState() -> Board {
        return boardInterface?.getBoardState() ?? Board(userPawn: Pawn(position: -1), oppositePawn:  Pawn(position: -1), walls: [])
    }
    
}
