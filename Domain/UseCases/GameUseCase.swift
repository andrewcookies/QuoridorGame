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
    @Published private var localBoard : Board = Board()

    private var subscribers: [AnyCancellable] = []

    init(userInfoInterface: UserInfoInterface?,
         boardInterface: BoardRepositoryInterface?,
         gameInterface: GameInterface?) {
        self.userInfoInterface = userInfoInterface
        self.boardInterface = boardInterface
        self.gameInterface = gameInterface
        
        self.gameInterface?.boardListener.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] board in
            guard let self = self else { return }
            self.boardInterface?.updateBoard(board: board)
            self.localBoard = board
            
        }).store(in: &subscribers)
    }
    
    func conflictsToEvent(conflict : BoardConflict) -> GameEvent {
        switch conflict {
            
        case .genericError:
            return .error

        case .wrongWallPosition:
            return .invalidWall
        
        case .noMoreWalls:
            return .noWall
            
        default:
            return .error
        }
    }
}

extension GameUseCase : GameUseCaseProtocol {
    func movePawn(newPawn: Pawn) async -> GameEvent {
        let conflict = boardInterface?.validateMovePawn(pawn: newPawn) ?? .genericError
        if conflict == .noConflicts {
            do {
                try await gameInterface?.updatePawn(pawn: newPawn)
                boardInterface?.movePawnOnTheBoard(pawn: newPawn)
                return GameEvent.waitingOpponentMove
            } catch {
                return GameEvent.error
            }
        } else {
            return .invalidPawn
        }
    }
    
    func insertWall(wall: Wall) async -> GameEvent {
        let conflict = boardInterface?.validateInsertWall(wall: wall) ?? .genericError
        if conflict == .noConflicts {
            do {
                try await gameInterface?.updateWalls(wall: wall)
                boardInterface?.insertWallOnTheBoard(wall: wall)
                return GameEvent.waitingOpponentMove
            } catch {
                return GameEvent.error
            }
            
        } else {
            return conflictsToEvent(conflict: conflict)
        }
    }
    
    
    var board: Published<Board>.Publisher {
        return $localBoard
    }
    
}
