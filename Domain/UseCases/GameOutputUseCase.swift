//
//  GameUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation


final class GameOutputUseCase {
    
    private var gameFactory : GameFactoryProtocol
    private var gameInterface : GameRepositoryOutputInterface

    init(gameFactory : GameFactoryProtocol,
         gameInterface : GameRepositoryOutputInterface) {
        self.gameFactory = gameFactory
        self.gameInterface = gameInterface
    }
    
}

extension GameOutputUseCase : GameOutputUseCaseProtocol {
    func allowedPawnMoves(pawn : Pawn) -> [Pawn] {
        return gameFactory.fetchAllowedCurrentPawn(pawn : pawn)
    }
    
    func quitMatch() async -> GameEvent {
        do{
            try await gameInterface.updateState(state: .quit)
            return .endGame
        } catch {
            return .error
        }
    }
    
    func movePawn(newPawn: Pawn) async -> GameEvent {
        let result = gameFactory.updatePawn(pawn: newPawn)
        do {
            switch result {
            case .success(let game):
                GameLog.shared.debug(message: "update Pawn", className: "GameOutputUseCase")
                try await gameInterface.updateGame(game: game)
                gameFactory.updateGame(game: game)
                return .waitingOpponentMove
            case .failure(let event):
                if event == .matchWon {
                    try await gameInterface.updateState(state: .win)
                }
                return event
            }
        } catch {
            GameLog.shared.debug(message: "Exception during call", className: "GameOutputUseCase")
            return .error
        }
    }
    
    func insertWall(wall: Wall) async -> GameEvent {
        let result = gameFactory.updateWall(wall: wall)
        do {
            switch result {
            case .success(let game):
                GameLog.shared.debug(message: "update wall - \(game.getTotalWalls())", className: "GameOutputUseCase")
                try await gameInterface.updateGame(game: game)
                gameFactory.updateGame(game: game)
                return .waitingOpponentMove
            case .failure(let event):
                GameLog.shared.debug(message: "insert wall conflict found \(event)", className: "GameOutputUseCase")
                return event
            }
            
        } catch {
            GameLog.shared.debug(message: "Exception during call", className: "GameOutputUseCase")
            return .error
        }
    }
}
