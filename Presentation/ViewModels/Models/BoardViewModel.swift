//
//  BoardViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
import Combine

protocol BoardViewModelProtocol {
    func movePawn(cellIndex: Int)
    func insertWall(cellIndex: Int, side: BoardCellSide)
    func quitMatch()
    func startMatch()
    func allowedPawnMoves() -> [Pawn]
}


final class BoardViewModel {
    
    private var useCases : GameOutputUseCaseProtocol?
    private var matchmakingUseCase : MatchMakingUseCaseProtocol?
    private var boardFactory : BoardFactoryInterface?

    var viewControllerInterface : BoardViewControllerProtocol?
    
    private var subscribers: [AnyCancellable] = []

    @Published private var currentGameEvent : GameEvent = .noEvent
    
    init(useCases: GameOutputUseCaseProtocol?,
         matchmakingUseCase : MatchMakingUseCaseProtocol?,
         boardFactory : BoardFactoryInterface?) {
        self.useCases = useCases
        self.matchmakingUseCase = matchmakingUseCase
        self.boardFactory = boardFactory
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
    
    
    func movePawn(cellIndex: Int) {
        if let pawn = boardFactory?.resolvePawn(cellIndex: cellIndex){
            Task {
                viewControllerInterface?.handelEvent(gameEvent: .waiting)
                let res = await useCases?.movePawn(newPawn: pawn)
                if let wrapper = boardFactory?.getBoardCellsFromPawn(newMove: pawn) {
                    if res == .invalidPawn || res == .waitingOpponentMove {
                        viewControllerInterface?.handelEvent(gameEvent: res ?? .error)
                    } else {
                        viewControllerInterface?.updateOpponentPawn(start: wrapper.startPosition, destination: wrapper.endPosition)
                    }
                }
            }
        }
    }
    
    func insertWall(cellIndex: Int, side: BoardCellSide) {
        if let wall = boardFactory?.resolveWall(cellIndex: cellIndex, side: side){
            Task {
                viewControllerInterface?.handelEvent(gameEvent: .waiting)
                let res = await useCases?.insertWall(wall: wall)
                if let wrapper = boardFactory?.getBoardCellsFromWall(newWall: wall) {
                    if res == .invalidWall || res == .waitingOpponentMove {
                        viewControllerInterface?.handelEvent(gameEvent: res ?? .error)
                    } else {
                        viewControllerInterface?.updateWall(topRight: wrapper.topRight, topLeft: wrapper.bottomLeft, bottomRight: wrapper.bottomRight, bottomLeft: wrapper.bottomLeft)
                    }
                }
            }
        }
    }
    
    func startMatch()  {
        guard let mUseCase = matchmakingUseCase else {
            viewControllerInterface?.handelEvent(gameEvent: .error)
            return
        }
        
        Task {
            let searchResult = await mUseCase.searchMatch()
            switch searchResult {
            case .success(let gameId):
                let joinResult = await mUseCase.joinMatch(gameId: gameId)
                switch joinResult {
                case .success(let game):
                    if let board = boardFactory?.updateBoard(game: game) {
                        viewControllerInterface?.initBoard(board: board)
                    }
                case .failure(_):
                    viewControllerInterface?.handelEvent(gameEvent: .error)
                }
            case .failure(let error):
                if error == .matchNotFound {
                    let createResult = await mUseCase.createMatch()
                    switch createResult {
                    case .success(let game):
                        if let board = boardFactory?.updateBoard(game: game) {
                            viewControllerInterface?.initBoard(board: board)
                        }
                    case .failure(_):
                        viewControllerInterface?.handelEvent(gameEvent: .error)
                    }
                } else {
                    viewControllerInterface?.handelEvent(gameEvent: .error)
                }
            }
        }
    }
}


