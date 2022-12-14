//
//  BoardViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
import Combine

protocol BoardViewModelProtocol {
    func movePawn(cellIndex : Int)
    func insertWall(cellIndex : Int, side : BoardCellSide)
    func quitMatch()
    func initializeMatch()
    func allowedPawnMoves() -> [Pawn]
    
    var gameEvent : Published<GameEvent>.Publisher { get }
}


final class BoardViewModel {
    
    private var useCases : GameOutputUseCaseProtocol?
    private var matchmakingUseCase : MatchMakingUseCaseProtocol?
    private var subscribers: [AnyCancellable] = []

    @Published private var currentGameEvent : GameEvent = .noEvent
    
    init(useCases: GameOutputUseCaseProtocol?,
         matchmakingUseCase : MatchMakingUseCaseProtocol?) {
        self.useCases = useCases
        self.matchmakingUseCase = matchmakingUseCase
    }
    
}

extension BoardViewModel : BoardViewModelProtocol {
    func insertWall(cellIndex: Int, side: BoardCellSide) {
        <#code#>
    }
    
    func movePawn(cellIndex: Int) {
        //TODO:
        
    }
    
    func allowedPawnMoves() -> [Pawn] {
        return useCases?.allowedPawnMoves() ?? []
    }
    
    func quitMatch() {
        Task {
            let res = await useCases?.quitMatch()
            currentGameEvent = res ?? .error
        }
    }
    
    
    var gameEvent: Published<GameEvent>.Publisher {
        $currentGameEvent
    }
    
    func movePawn(pawn: Pawn) {
        Task {
            let res = await useCases?.movePawn(newPawn: pawn)
            currentGameEvent = res ?? .error
        }
    }
    
    func insertWall(wall: Wall) {
        Task {
            let res = await useCases?.insertWall(wall: wall)
            currentGameEvent = res ?? .error
        }
    }
    
    func initializeMatch() {
        Task {
            let res = await matchmakingUseCase?.initMatch()
            currentGameEvent = res ?? .error
        }
    }
}


