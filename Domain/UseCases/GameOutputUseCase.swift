//
//  GameUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation


final class GameOutputUseCase {
    
    private var validator : ValidatorInterface?
    private var gatewayOutputInterface : GameGatewayOutputInterface?
    
    @Published private var localGame : Game = Game.defaultValue

    init(validator : ValidatorInterface?,
         gatewayOutputInterface : GameGatewayOutputInterface?) {
        
        self.gatewayOutputInterface = gatewayOutputInterface
        self.validator = validator
    }
    
}

extension GameOutputUseCase : GameOutputUseCaseProtocol {
    func allowedPawnMoves() -> [Pawn] {
        return validator?.fetchAllowedPawn() ?? []
    }
    
    func quitMatch() async -> GameEvent {
        do{
            try await gatewayOutputInterface?.updateState(state: .quit)
            return .endGame
        } catch {
            return .error
        }
    }
    
    func movePawn(newPawn: Pawn) async -> GameEvent {
        let event = validator?.validateMovePawn(pawn: newPawn) ?? .error
        do{
            if event == .noEvent {
                GameLog.shared.debug(message: "update Pawn", className: "GameOutputUseCase")
                try await gatewayOutputInterface?.updatePawn(pawn: newPawn)
                return .waitingOpponentMove
            } else if event == .matchWon {
                GameLog.shared.debug(message: "match Won", className: "GameOutputUseCase")
                try await gatewayOutputInterface?.updateState(state: .win )
                return  event
            } else {
                GameLog.shared.debug(message: "move pawn conflict found \(event)", className: "GameOutputUseCase")
                return event
            }
        } catch {
            GameLog.shared.debug(message: "Exception during call", className: "GameOutputUseCase")
            return .error
        }
    }
    
    func insertWall(wall: Wall) async -> GameEvent {
        let event = validator?.validateInsertWall(wall: wall) ?? .error
        do{
            if event == .noEvent {
                GameLog.shared.debug(message: "insert wall", className: "GameOutputUseCase")
                try await gatewayOutputInterface?.updateWall(wall: wall)
                return .waitingOpponentMove
            } else {
                GameLog.shared.debug(message: "insert wall conflict found \(event)", className: "GameOutputUseCase")
                return event
            }
        } catch {
            GameLog.shared.debug(message: "Exception during call", className: "GameOutputUseCase")
            return .error
        }
    }
}
