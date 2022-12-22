//
//  MatchmakingViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 04/12/22.
//

import Foundation
import Combine

protocol GameInputViewModelProtocol {
    func getWall(cellIndex: Int, side: BoardCellSide) -> Wall
}

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
            if let b = boardFactory?.resolveBoard(game: game){
                currentBoard = b
                viewControllerProtocol?.initBoard(board: b)
            }
            
        case .opponentMovePawn:
            let newPosition = game.lastMove.pawnMove
            if let wrapper = boardFactory?.movePawn(currentBoard: currentBoard, newMove: newPosition) {
                currentBoard = wrapper.updatedBoard
                viewControllerProtocol?.updateOpponentPawn(start: wrapper.startPosition, destination: wrapper.endPosition)
            }
            
        case .opponentInsertWall:
            let newWall = game.lastMove.wallMove
            if let wrapper = boardFactory?.insertWall(currentBoard: currentBoard, newWall: newWall) {
                currentBoard = wrapper.updatedBoard
                viewControllerProtocol?.updateWall(topRight: wrapper.topRight, topLeft: wrapper.topLeft, bottomRight: wrapper.bottomRight, bottomLeft: wrapper.bottomLeft)
            }
        case .noMove:
            break
        }
    }
    
}

extension GameInputViewModel : GameInputViewModelProtocol {
    func getWall(cellIndex: Int, side: BoardCellSide) -> Wall {
        let drawMode = currentBoard.drawMode
        var wall = Wall.initValue
        
        if side == .topSide {
            let topLeftIndex = drawMode == .normal ? cellIndex - bufferTopDownCell : cellIndex + bufferTopDownCell
            let topRigthIndex = drawMode == .normal ? cellIndex - bufferTopDownCell + bufferLeftRightCell : cellIndex + bufferTopDownCell - bufferLeftRightCell
            let bottomRigthIndex = drawMode == .normal ? cellIndex + bufferLeftRightCell : cellIndex - bufferLeftRightCell
            let bottomLeftIndex =  cellIndex
            wall = Wall(orientation: .horizontal, topLeftCell: topLeftIndex, topRightCell: topRigthIndex, bottomLeftCell: bottomLeftIndex, bottomRightCell: bottomRigthIndex)
        }
        
        if side == .bottomSide {
            let topLeftIndex = cellIndex
            let topRigthIndex = drawMode == .normal ? cellIndex + bufferLeftRightCell : cellIndex - bufferLeftRightCell
            let bottomRigthIndex = drawMode == .normal ? cellIndex + bufferTopDownCell + bufferLeftRightCell : cellIndex - bufferTopDownCell - bufferLeftRightCell
            let bottomLeftIndex =  drawMode == .normal ? cellIndex + bufferTopDownCell : cellIndex - bufferTopDownCell
            wall = Wall(orientation: .horizontal, topLeftCell: topLeftIndex, topRightCell: topRigthIndex, bottomLeftCell: bottomLeftIndex, bottomRightCell: bottomRigthIndex)
        }
        
        if side == .rightSide {
            let topLeftIndex = drawMode == .normal ? cellIndex - bufferTopDownCell : cellIndex + bufferTopDownCell
            let topRigthIndex = drawMode == .normal ? cellIndex - bufferTopDownCell + bufferLeftRightCell : cellIndex + bufferTopDownCell - bufferLeftRightCell
            let bottomRigthIndex = drawMode == .normal ? cellIndex + bufferLeftRightCell : cellIndex - bufferLeftRightCell
            let bottomLeftIndex = cellIndex
            wall = Wall(orientation: .vertical, topLeftCell: topLeftIndex, topRightCell: topRigthIndex, bottomLeftCell: bottomLeftIndex, bottomRightCell: bottomRigthIndex)
        }
        
        if side == .leftSide {
            let topLeftIndex = drawMode == .normal ? cellIndex - bufferTopDownCell - bufferLeftRightCell : cellIndex + bufferTopDownCell + bufferLeftRightCell
            let topRigthIndex = drawMode == .normal ? cellIndex - bufferTopDownCell : cellIndex + bufferTopDownCell
            let bottomRigthIndex = cellIndex
            let bottomLeftIndex = drawMode == .normal ? cellIndex - bufferLeftRightCell : cellIndex + bufferLeftRightCell
            wall = Wall(orientation: .vertical, topLeftCell: topLeftIndex, topRightCell: topRigthIndex, bottomLeftCell: bottomLeftIndex, bottomRightCell: bottomRigthIndex)
        }
        return wall
    }
}
