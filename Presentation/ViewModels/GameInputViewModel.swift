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
    private var userInfo : UserInfoInterface?
    
    var viewControllerProtocol : BoardViewControllerProtocol?
    
    init(userInfo : UserInfoInterface?){
        self.userInfo = userInfo
        currentBoard = Board(cells: [[]], player: Player.startPlayerValue, opponent: Player.startOpponentValue, drawMode: .normal)
    }
    
    
    private func initBoard(game : Game) -> Board {
        let currentPlayerId = userInfo?.getUserInfo().userId
        let drawMode: DrawMode = currentPlayerId == game.player1.playerId ? .normal : .reverse
        var currentPlayer = game.player1
        var opponentPlayer = game.player2
        var rows = [(0..<numberOfCellPerRow)]
        var columns  = [(0..<numberOfCellPerRow)]
        
        if drawMode == .reverse {
            rows = rows.reversed()
            columns = columns.reversed()
            currentPlayer = game.player2
            opponentPlayer = game.player1
        }
        
        
        var cells = [[BoardCell]]()
        for row in 0..<numberOfCellPerRow {
            var boardRow = [BoardCell]()
            for column in 0..<numberOfCellPerRow {
                let currentIndex = row+column
                var contentType = BoardContentType.empty
                var topBorder = BorderType.empty
                var leftBorder = BorderType.empty
                var rightBorder = BorderType.empty
                var bottomBorder = BorderType.empty
                
                if topCellsBorder.contains(currentIndex) {
                    topBorder = .boardBorder
                }
                
                if bottomCellsBorder.contains(currentIndex) {
                    bottomBorder = .boardBorder
                }
                
                if rightCellsBorder.contains(currentIndex) {
                    rightBorder = .boardBorder
                }
                
                if leftCellsBorder.contains(currentIndex) {
                    leftBorder = .boardBorder
                }
                
                if currentIndex == currentPlayer.pawnPosition.position {
                    contentType = .playerPawn
                }
                
                if currentIndex == opponentPlayer.pawnPosition.position {
                    contentType = .opponentPawn
                }
                
                let boardCell = BoardCell(index: currentIndex, topBorder: topBorder, leftBorder: leftBorder, rightBorder: rightBorder, bottomBorder: bottomBorder, contentType: contentType)
                boardRow.append(boardCell)
                
            }
            cells.append(boardRow)
        }
        return Board(cells: cells, player: currentPlayer, opponent: opponentPlayer, drawMode: drawMode)
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
        let lastMove = game.lastMove
        let currentPlayerId = userInfo?.getUserInfo().userId
        if currentPlayerId != lastMove.playerId {
            if game.gameMoves.count == 2 {
                //the opponent player accepted to play and put its pawn
                currentBoard = initBoard(game: game)
                viewControllerProtocol?.initBoard(board: currentBoard)
            } else {
                //the opponent make a move
                if lastMove.moveType == .movePawn {
                    //move pawn
                    let newPosition = lastMove.pawnMove.position
                    let newRow = newPosition/10
                    let newColumn = newPosition%10
                    
            
                    for (rowId,_) in currentBoard.cells.enumerated() {
                        for (columnId,_) in currentBoard.cells.enumerated() {
                            let cell = currentBoard.cells[rowId][columnId]
                            if cell.contentType == .opponentPawn {
                                currentBoard.cells[rowId][columnId].contentType = .empty
                                currentBoard.cells[newRow][newColumn].contentType = .playerPawn
                                viewControllerProtocol?.updateOpponentPawn(start: currentBoard.cells[rowId][columnId], destination: currentBoard.cells[newRow][newColumn])
                                break
                            }
                        }
                    }
                    
            
                } else {
                    //insert wall
                    let wall = lastMove.wallMove
                    
                    let topRightIndex = wall.topRightCell
                    let topRightRow = topRightIndex/10
                    let topRightColumn = topRightIndex%10
                    if wall.orientation == .horizontal {
                        currentBoard.cells[topRightRow][topRightColumn].bottomBorder = .wall
                    } else {
                        currentBoard.cells[topRightRow][topRightColumn].leftBorder = .wall
                    }
                    let topRightCell = currentBoard.cells[topRightRow][topRightColumn]
                    
                    let bottomRightIndex = wall.bottomRightCell
                    let bottomRightRow = bottomRightIndex/10
                    let bottomRightColumn = bottomRightIndex%10
                    if wall.orientation == .horizontal {
                        currentBoard.cells[bottomRightRow][bottomRightColumn].topBorder = .wall
                    } else {
                        currentBoard.cells[bottomRightRow][bottomRightColumn].leftBorder = .wall
                    }
                    let bottomRightCell = currentBoard.cells[bottomRightRow][bottomRightColumn]
                    
                    let topLeftIndex = wall.topLeftCell
                    let topLeftRow = topLeftIndex/10
                    let topLeftColumn = topLeftIndex%10
                    if wall.orientation == .horizontal {
                        currentBoard.cells[topLeftRow][topLeftColumn].bottomBorder = .wall
                    } else {
                        currentBoard.cells[topLeftRow][topLeftColumn].rightBorder = .wall
                    }
                    let topLeftCell = currentBoard.cells[topLeftRow][topLeftColumn]
                    
                    let bottomLeftIndex = wall.bottomLeftCell
                    let bottomLeftRow = bottomLeftIndex/10
                    let bottomLeftColumn = bottomLeftIndex%10
                    if wall.orientation == .horizontal {
                        currentBoard.cells[bottomLeftRow][bottomLeftColumn].topBorder = .wall
                    } else {
                        currentBoard.cells[bottomLeftRow][bottomLeftColumn].rightBorder = .wall
                    }
                    let bottomLeftCell = currentBoard.cells[bottomLeftRow][bottomLeftColumn]
                    
                    viewControllerProtocol?.updateWall(topRight: topRightCell, topLeft: topLeftCell, bottomRight: bottomRightCell, bottomLeft: bottomLeftCell)
                    
                }
            }
            
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
