//
//  GameUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation
import Combine


final class GameUseCase {
    
    private var userInfoInterface : UserInfoInterface?
    private var boardInterface : BoardRepositoryInterface?
    private var gameInterface : GameInterface?
    @Published private var localGameEvent : GameEvent = .noEvent
    
    init(userInfoInterface: UserInfoInterface?,
         boardInterface: BoardRepositoryInterface?,
         gameInterface: GameInterface?) {
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
        
        let conflict = boardInterface?.validateMovePawn(pawn: newPawn) ?? .genericError
        if conflict == .noConflicts {
            boardInterface?.movePawnOnTheBoard(pawn: newPawn)
            //  gameInterface?
        }
    }
    
    func insertWall(wall: Wall) {
        let conflict = boardInterface?.validateInsertWall(wall: wall) ?? .genericError
        if conflict == .noConflicts {
            boardInterface?.insertWallOnTheBoard(wall: wall)
            //  gameInterface?
        } else {
            localGameEvent = conflictsToEvent(conflict: conflict)
        }
    }
    
    func getBoardState() -> Board {
        return boardInterface?.getBoardState() ?? Board()
    }
    
}
