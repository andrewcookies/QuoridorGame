//
//  GameUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation


final class GameUseCase {
    
    private var validator : ValidatorInterface?
    private var gatewayOutputInterface : GameGatewayOutputInterface?
    
    @Published private var localGame : Game = Game.defaultValue

    init(validator : ValidatorInterface?,
         gatewayOutputInterface : GameGatewayOutputInterface?) {
        
        self.gatewayOutputInterface = gatewayOutputInterface
        self.validator = validator
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
            try await gatewayOutputInterface?.searchMatch()
            return GameEvent.waitingOpponentMove
        } catch {
            return GameEvent.error
        }
    }
    
    func movePawn(newPawn: Pawn) async -> GameEvent {
        let conflict = validator?.validateMovePawn(pawn: newPawn) ?? [.genericError]
        if conflict.first == .noConflicts {
            do {
                try await gatewayOutputInterface?.updatePawn(pawn: newPawn)
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
                try await gatewayOutputInterface?.updateWall(wall: wall)
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
