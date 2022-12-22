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
    private var boardFactory : BoardFactoryInterface?
    
    var viewControllerProtocol : BoardViewControllerProtocol?
    let defaultBoard = Board(cells: [[]], player: Player.startPlayerValue, opponent: Player.startOpponentValue, drawMode: .normal)
    
    init(boardFactory : BoardFactoryInterface?){
        self.boardFactory = boardFactory
        currentBoard = defaultBoard
    }
    
}

extension GameInputViewModel : PresentationLayerInputListenerInterface {
    func opponentRequestRestartGame(game: Game) {
        //TODO: handle
    }
    
    func opponentQuitMatch(game: Game) {
        //TODO: handle
    }
    
    func opponentWonMatch(game: Game) {
        //TODO: handle
    }
    
    func opponentMadeMove(game: Game) {
        let stage = boardFactory?.gameState(game: game) ?? .noMove
        switch stage {
        case .gameAlreadyStarted:
            if let b = boardFactory?.updateBoard(game: game){
                currentBoard = b
                viewControllerProtocol?.initBoard(board: b)
            }
            
        case .opponentMovePawn:
            let newPosition = game.lastMove.pawnMove
            if let wrapper = boardFactory?.getBoardCellsFromPawn(newMove: newPosition) {
                currentBoard = wrapper.updatedBoard
                viewControllerProtocol?.updateOpponentPawn(start: wrapper.startPosition, destination: wrapper.endPosition)
            }
            
        case .opponentInsertWall:
            let newWall = game.lastMove.wallMove
            if let wrapper = boardFactory?.getBoardCellsFromWall(newWall: newWall) {
                currentBoard = wrapper.updatedBoard
                viewControllerProtocol?.updateWall(topRight: wrapper.topRight, topLeft: wrapper.topLeft, bottomRight: wrapper.bottomRight, bottomLeft: wrapper.bottomLeft)
            }
        case .noMove:
            break
        }
    }
    
}

