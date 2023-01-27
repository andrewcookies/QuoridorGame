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
        let game = gameFactory.updatePawn(pawn: newPawn)
        do {
            GameLog.shared.debug(message: "update Pawn \(newPawn.position)", className: "GameOutputUseCase")
            try await gameInterface.updateGame(game: game)
            gameFactory.updateGame(game: game)
            if game.state == .win {
                return .matchWon
            } else {
                return .waitingOpponentMove
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
