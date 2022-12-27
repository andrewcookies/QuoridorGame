//
//  MatchmakingViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 04/12/22.
//

import Foundation
import Combine


final class GameInputViewModel {
    private var currentBoard : Board
    private var boardFactory : BoardFactoryInterface
    
    var viewControllerProtocol : BoardViewControllerProtocol?
    let defaultBoard = Board(cells: [[]], player: Player.startPlayerValue, opponent: Player.startOpponentValue, drawMode: .normal)
    
    init(boardFactory : BoardFactoryInterface){
        self.boardFactory = boardFactory
        currentBoard = defaultBoard
    }
    
}

extension GameInputViewModel : PresentationLayerInputListenerInterface {
    func opponentRequestRestartGame(game: Game) {
        //TODO: handle
    }
    
    func opponentQuitMatch(game: Game) {
        viewControllerProtocol?.handelEvent(gameEvent: .endGame)
    }
    
    func opponentWonMatch(game: Game) {
        let newPosition = game.lastMove.pawnMove
        let wrapper = boardFactory.getBoardCellsFromPawn(newMove: newPosition, contentType : .opponentPawn)
        currentBoard = wrapper.updatedBoard
        viewControllerProtocol?.updateOpponentPawn(start: wrapper.startPosition, destination: wrapper.endPosition)
        viewControllerProtocol?.handelEvent(gameEvent: .matchLost)
    }
    
    func opponentMadeMove(game: Game) {
        let stage = boardFactory.gameState(game: game)
        switch stage {
        case .gameAlreadyStarted:
            currentBoard = boardFactory.updateBoard(game: game)
            viewControllerProtocol?.initBoard(board: currentBoard)
            
            
        case .opponentMovePawn:
            let newPosition = game.lastMove.pawnMove
            let wrapper = boardFactory.getBoardCellsFromPawn(newMove: newPosition, contentType : .opponentPawn)
            currentBoard = wrapper.updatedBoard
            viewControllerProtocol?.updateOpponentPawn(start: wrapper.startPosition, destination: wrapper.endPosition)
            
            
        case .opponentInsertWall:
            let newWall = game.lastMove.wallMove
            let wrapper = boardFactory.getBoardCellsFromWall(newWall: newWall)
            currentBoard = wrapper.updatedBoard
            viewControllerProtocol?.updateWall(topRight: wrapper.topRight, topLeft: wrapper.topLeft, bottomRight: wrapper.bottomRight, bottomLeft: wrapper.bottomLeft)
            
        case .noMove:
            break
        }
    }
    
}

