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
    func close()
}

struct BoardViewNavigation {
    let close : () -> ()
}

final class BoardViewModel {
    
    private var navigation : BoardViewNavigation
    private var useCases : GameOutputUseCaseProtocol
    private var matchmakingUseCase : MatchMakingUseCaseProtocol
    private var boardFactory : BoardFactoryInterface

    var viewControllerInterface : BoardViewControllerProtocol?
    
    private var subscribers: [AnyCancellable] = []
    
    init(navigation : BoardViewNavigation,
         useCases: GameOutputUseCaseProtocol,
         matchmakingUseCase : MatchMakingUseCaseProtocol,
         boardFactory : BoardFactoryInterface) {
        self.navigation = navigation
        self.useCases = useCases
        self.matchmakingUseCase = matchmakingUseCase
        self.boardFactory = boardFactory
    }
    
}

extension BoardViewModel : BoardViewModelProtocol {
    func close() {
        navigation.close()
    }
    
    func allowedPawnMoves() -> [Pawn] {
        return useCases.allowedPawnMoves()
    }
    
    func quitMatch() {
        Task {
            let res = await useCases.quitMatch()
            DispatchQueue.main.async {
                self.viewControllerInterface?.handelEvent(gameEvent: res)
            }
        }
    }
    
    
    func movePawn(cellIndex: Int) {
        let pawn = boardFactory.resolvePawn(cellIndex: cellIndex)
        Task {
            viewControllerInterface?.handelEvent(gameEvent: .waiting)
            let res = await useCases.movePawn(newPawn: pawn)
            DispatchQueue.main.async {
                self.viewControllerInterface?.handelEvent(gameEvent: res)
                if res == .waitingOpponentMove {
                    let wrapper = self.boardFactory.getBoardCellsFromPawn(newMove: pawn, contentType: .playerPawn)
                    self.viewControllerInterface?.updateOpponentPawn(start: wrapper.startPosition, destination: wrapper.endPosition)
                }
            }
        }
        
    }
    
    func insertWall(cellIndex: Int, side: BoardCellSide) {
        let wall = boardFactory.resolveWall(cellIndex: cellIndex, side: side)
        Task {
            viewControllerInterface?.handelEvent(gameEvent: .waiting)
            let res = await useCases.insertWall(wall: wall)
            DispatchQueue.main.async {
                self.viewControllerInterface?.handelEvent(gameEvent: res )
                if res == .waitingOpponentMove {
                    let wrapper = self.boardFactory.getBoardCellsFromWall(newWall: wall)
                    self.viewControllerInterface?.updateWall(topRight: wrapper.topRight, topLeft: wrapper.topLeft, bottomRight: wrapper.bottomRight, bottomLeft: wrapper.bottomLeft)
                }
            }
        }
    }
    
    func startMatch()  {
        viewControllerInterface?.handelEvent(gameEvent: .searchingOpponents)
        Task {
            let searchResult = await matchmakingUseCase.searchMatch()
            switch searchResult {
            case .success(let gameId):
                let joinResult = await matchmakingUseCase.joinMatch(gameId: gameId)
                switch joinResult {
                    
                case .success(let game):
                    DispatchQueue.main.async {
                        let board = self.boardFactory.getBoardFromGame(game: game)
                        self.viewControllerInterface?.initBoard(board: board)
                    }
                    
                case .failure(_):
                    DispatchQueue.main.async {
                        self.viewControllerInterface?.handelEvent(gameEvent: .error)
                    }
                }
                
            case .failure(let error):
                if error == .matchNotFound {
                    let createResult = await matchmakingUseCase.createMatch()
                    switch createResult {
                    case .success(let game):
                        DispatchQueue.main.async {
                            let board = self.boardFactory.getBoardFromGame(game: game)
                            self.viewControllerInterface?.initBoard(board: board)
                        }
                        
                    case .failure(_):
                        DispatchQueue.main.async {
                            self.viewControllerInterface?.handelEvent(gameEvent: .error)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.viewControllerInterface?.handelEvent(gameEvent: .error)
                    }
                }
            }
        }
    }
    
    
}


