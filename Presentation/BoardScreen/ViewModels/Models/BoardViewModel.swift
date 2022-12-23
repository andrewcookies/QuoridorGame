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
    
    private var useCases : GameOutputUseCaseProtocol
    private var matchmakingUseCase : MatchMakingUseCaseProtocol
    private var boardFactory : BoardFactoryInterface

    var viewControllerInterface : BoardViewControllerProtocol?
    
    private var subscribers: [AnyCancellable] = []
    
    init(useCases: GameOutputUseCaseProtocol,
         matchmakingUseCase : MatchMakingUseCaseProtocol,
         boardFactory : BoardFactoryInterface) {
        self.useCases = useCases
        self.matchmakingUseCase = matchmakingUseCase
        self.boardFactory = boardFactory
    }
    
}

extension BoardViewModel : BoardViewModelProtocol {
    func allowedPawnMoves() -> [Pawn] {
        return useCases.allowedPawnMoves()
    }
    
    func quitMatch() {
        Task {
            let res = await useCases.quitMatch()
            viewControllerInterface?.handelEvent(gameEvent: res)
        }
    }
    
    
    func movePawn(cellIndex: Int) {
        let pawn = boardFactory.resolvePawn(cellIndex: cellIndex)
        Task {
            viewControllerInterface?.handelEvent(gameEvent: .waiting)
            let res = await useCases.movePawn(newPawn: pawn)
            viewControllerInterface?.handelEvent(gameEvent: res)
            if res == .waitingOpponentMove {
                let wrapper = boardFactory.getBoardCellsFromPawn(newMove: pawn)
                viewControllerInterface?.updateOpponentPawn(start: wrapper.startPosition, destination: wrapper.endPosition)
            }
        }
        
    }
    
    func insertWall(cellIndex: Int, side: BoardCellSide) {
        let wall = boardFactory.resolveWall(cellIndex: cellIndex, side: side)
        Task {
            viewControllerInterface?.handelEvent(gameEvent: .waiting)
            let res = await useCases.insertWall(wall: wall)
            viewControllerInterface?.handelEvent(gameEvent: res )
            if res == .waitingOpponentMove {
                let wrapper = boardFactory.getBoardCellsFromWall(newWall: wall)
                viewControllerInterface?.updateWall(topRight: wrapper.topRight, topLeft: wrapper.bottomLeft, bottomRight: wrapper.bottomRight, bottomLeft: wrapper.bottomLeft)
            }
        }
    }
    
    func startMatch()  {
        
        Task {
            viewControllerInterface?.handelEvent(gameEvent: .searchingOpponents)
            let searchResult = await matchmakingUseCase.searchMatch()
            switch searchResult {
            case .success(let gameId):
                viewControllerInterface?.handelEvent(gameEvent: .joiningMatch)
                let joinResult = await matchmakingUseCase.joinMatch(gameId: gameId)
                switch joinResult {
                case .success(let game):
                    let board = boardFactory.updateBoard(game: game)
                    viewControllerInterface?.initBoard(board: board)
                    
                case .failure(_):
                    viewControllerInterface?.handelEvent(gameEvent: .error)
                }
                
            case .failure(let error):
                if error == .matchNotFound {
                    let createResult = await matchmakingUseCase.createMatch()
                    switch createResult {
                    case .success(let game):
                        let board = boardFactory.updateBoard(game: game)
                        viewControllerInterface?.initBoard(board: board)
                        
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


