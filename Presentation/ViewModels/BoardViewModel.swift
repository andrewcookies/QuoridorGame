//
//  BoardViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
import Combine

protocol BoardViewModelProtocol {
    func movePawn(index : Int)
    func insertWall(index : Int)
    func initializeMatch()
    
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
    
    var gameEvent: Published<GameEvent>.Publisher {
        $currentGameEvent
    }
    
    func movePawn(index: Int) {
        let p = Pawn(position: index)
        Task {
            let res = await useCases?.movePawn(newPawn: p)
            currentGameEvent = res ?? .error
        }
    }
    
    func insertWall(index: Int) {
        let w = Wall(orientation: .horizontal, position: .bottom, topLeftCell: index)
        Task {
            let res = await useCases?.insertWall(wall: w)
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


