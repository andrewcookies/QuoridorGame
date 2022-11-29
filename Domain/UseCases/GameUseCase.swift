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
            boardInterface?.updateBoard(board: board)
            self.localBoard = board
            
        }).store(in: &subscribers)
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
    
    var board: Published<Board>.Publisher {
        return $localBoard
    }
    
    
    var gameEvent: Published<GameEvent>.Publisher {
        $localGameEvent
    }
    
    func movePawn(newPawn: Pawn) {
        
        let conflict = boardInterface?.validateMovePawn(pawn: newPawn) ?? .genericError
        if conflict == .noConflicts {
            localGameEvent = .waiting
            Task.init {
                do {
                    try await gameInterface?.updatePawn(pawn: newPawn)
                    localGameEvent = .waitingOpponentMove
                    boardInterface?.movePawnOnTheBoard(pawn: newPawn)
                } catch {
                    localGameEvent = .genericError
                }
            }
        }
    }
    
    func insertWall(wall: Wall) {
        let conflict = boardInterface?.validateInsertWall(wall: wall) ?? .genericError
        if conflict == .noConflicts {
            localGameEvent = .waiting
            Task.init {
                do {
                    try await gameInterface?.updateWalls(wall: wall)
                    localGameEvent = .waitingOpponentMove
                    boardInterface?.insertWallOnTheBoard(wall: wall)
                } catch {
                    localGameEvent = .genericError
                }
            }
        } else {
            localGameEvent = conflictsToEvent(conflict: conflict)
        }
    }
    
}
