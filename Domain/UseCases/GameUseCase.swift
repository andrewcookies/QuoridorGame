//
//  GameUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation
import Combine


final class GameUseCase {
    
    private var gameRepoWriterInterface : GameRepositoryWriteInterface?
    private var validator : ValidatorInterface?
    private var gameInterface : GameInterface?
    
    @Published private var localGame : Game = Game.defaultValue

    private var subscribers: [AnyCancellable] = []

    init(gameRepoWriterInterface: GameRepositoryWriteInterface?,
         validator : ValidatorInterface?,
         gameInterface: GameInterface?) {
        
        self.gameRepoWriterInterface = gameRepoWriterInterface
        self.gameInterface = gameInterface
        self.gameInterface?.gameListener.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] game in
            guard let self = self else { return }
            self.gameRepoWriterInterface?.updateGame(game: game)
            self.localGame = game
            
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
    func initMatch() async -> GameEvent {
        do {
            //TODO: check opponents turn
            try await gameInterface?.searchMatch()
            return GameEvent.waitingOpponentMove
        } catch {
            return GameEvent.error
        }
    }
    
    func movePawn(newPawn: Pawn) async -> GameEvent {
        let conflict = validator?.validateMovePawn(pawn: newPawn) ?? [.genericError]
        if conflict.first == .noConflicts {
            do {
                try await gameInterface?.updatePawn(pawn: newPawn)
                gameRepoWriterInterface?.movePawnOnTheBoard(pawn: newPawn)
                return GameEvent.waitingOpponentMove
            } catch {
                return GameEvent.error
            }
        } else {
            return .invalidPawn
        }
    }
    
    func insertWall(wall: Wall) async -> GameEvent {
        let conflict = validator?.validateInsertWall(wall: wall) ?? [.genericError]
        if conflict.first == .noConflicts {
            do {
                try await gameInterface?.updateWalls(wall: wall)
                gameRepoWriterInterface?.insertWallOnTheBoard(wall: wall)
                return GameEvent.waitingOpponentMove
            } catch {
                return GameEvent.error
            }
            
        } else {
            return conflictsToEvent(conflict: conflict.first ?? .genericError)
        }
    }
    
    
    var match: Published<Game>.Publisher {
        return $localGame
    }
    
}
