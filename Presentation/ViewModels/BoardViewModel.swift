//
//  BoardViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
import Combine

protocol BoardViewModelProtocol {
    func movePawn(pawn : Pawn)
    func insertWall(wall : Wall)
    func quitMatch()
    func startMatch() -> Result<Board,MatchMakingError>
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
    
    func startMatch() -> Result<Board,MatchMakingError> {
        guard let mUseCase = matchmakingUseCase else { return .failure(.APIError)}
        Task {
            let searchResult = await mUseCase.searchMatch()
            switch searchResult {
            case .success(let gameId):
                let joinResult = await mUseCase.joinMatch(gameId: gameId)
                switch joinResult {
                case .success(let game):
                    //HANDLE GAME: convert with BoardFactory
                    return .failure(.APIError)
                case .failure(let failure):
                    return failure
                }
            case .failure(let error):
                if error == .matchNotFound {
                    let createResult = await mUseCase.createMatch()
                } else {
                    return error
                }
            }
        }
    }
}


