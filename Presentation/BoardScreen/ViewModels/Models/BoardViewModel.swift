//
//  BoardViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
import Combine

protocol BoardViewModelProtocol {
    var currentPawnPosition : Int { get }
    var currentPlayerName : String { get }
    var opponentRemainingWalls : Int { get }

    func movePawn(cellIndex: Int)
    func insertWall(cellIndex: Int, side: BoardCellSide)
    func quitMatch()
    func startMatch()
    func allowedPawnMoves(cellIndex : Int) -> [Pawn]
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
    
    private var currentBoard : Board?

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
    var opponentRemainingWalls: Int {
        boardFactory.opponentRemainingWalls
    }
    
    var currentPawnPosition: Int {
        boardFactory.playerPosition
    }
    
    var currentPlayerName : String {
        boardFactory.playerName
    }

    func close() {
        navigation.close()
    }
    
    func allowedPawnMoves(cellIndex : Int) -> [Pawn] {
        return useCases.allowedPawnMoves(pawn : Pawn(position: cellIndex))
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
        GameLog.shared.debug(message: "move pawn \(cellIndex)", className: "BoardViewModel")
        let pawn = boardFactory.resolvePawn(cellIndex: cellIndex)
        viewControllerInterface?.handelEvent(gameEvent: .waiting)
        Task {
            let res = await useCases.movePawn(newPawn: pawn)
            DispatchQueue.main.async {
                self.viewControllerInterface?.handelEvent(gameEvent: res)
                if res == .waitingOpponentMove {
                    let wrapper = self.boardFactory.getBoardCellsFromPawn(newMove: pawn, contentType: .playerPawn)
                    self.currentBoard = wrapper.updatedBoard
                    self.viewControllerInterface?.updatePawnOnBoard(start: wrapper.startPosition, destination: wrapper.endPosition)
                }
            }
        }
        
    }
    
    
    
    func insertWall(cellIndex: Int, side: BoardCellSide) {
        GameLog.shared.debug(message: "insert wall \(cellIndex) - \(side)", className: "BoardViewModel")
        let wall = boardFactory.resolveWall(cellIndex: cellIndex, side: side)
        viewControllerInterface?.handelEvent(gameEvent: .waiting)
        Task {
            let res = await useCases.insertWall(wall: wall)
            DispatchQueue.main.async {
                self.viewControllerInterface?.handelEvent(gameEvent: res)
                if res == .waitingOpponentMove {
                    let wrapper = self.boardFactory.getBoardCellsFromWall(newWall: wall)
                    self.currentBoard = wrapper.updatedBoard
                    self.viewControllerInterface?.updateWallOnBoard(topRight: wrapper.topRight, topLeft: wrapper.topLeft, bottomRight: wrapper.bottomRight, bottomLeft: wrapper.bottomLeft)
                }
            }
        }
    }
    
    func startMatch()  {
        viewControllerInterface?.handelEvent(gameEvent: .searchingOpponents)
        Task {
          //  try await Task.sleep(nanoseconds: 4000000000) //mock waiting
            let searchResult = await matchmakingUseCase.searchMatch()
            switch searchResult {
            case .success(let gameId):
                let joinResult = await matchmakingUseCase.joinMatch(gameId: gameId)
                switch joinResult {
                    
                case .success(let game):
                    DispatchQueue.main.async {
                        let board = self.boardFactory.getBoardFromGame(game: game)
                        self.viewControllerInterface?.joinBoard(board: board)
                        self.viewControllerInterface?.handelEvent(gameEvent: .waitingOpponentMove)
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
                            self.viewControllerInterface?.handelEvent(gameEvent: .searchingOpponents)
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


