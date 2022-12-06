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
    func quitMatch() async -> GameEvent {
        do{
            try await gatewayOutputInterface?.updateState(state: .terminated)
            return .endGame
        } catch {
            return .error
        }
    }
    
    func movePawn(newPawn: Pawn) async -> GameEvent {
        let event = validator?.validateMovePawn(pawn: newPawn) ?? .error
        do{
            if event == .noEvent {
                try await gatewayOutputInterface?.updatePawn(pawn: newPawn)
                return .waitingOpponentMove
            } else if event == .matchWon || event == .matchLost {
                try await gatewayOutputInterface?.updateState(state: event == .matchWon ? .win : .lost)
                return  event
            } else {
                return event
            }
        } catch {
            return .error
        }
    }
    
    func insertWall(wall: Wall) async -> GameEvent {
        let event = validator?.validateInsertWall(wall: wall) ?? .error
        do{
            if event == .noEvent {
                try await gatewayOutputInterface?.updateWall(wall: wall)
                return .waitingOpponentMove
            } else if event == .matchWon || event == .matchLost {
                try await gatewayOutputInterface?.updateState(state: event == .matchWon ? .win : .lost)
                return  event
            } else {
                return event
            }
        } catch {
            return .error
        }
    }
}
