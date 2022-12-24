//
//  BoardFactory.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 22/12/22.
//

import Foundation

enum GameStage {
    case gameAlreadyStarted
    case opponentMovePawn
    case opponentInsertWall
    case noMove
}
struct PawnWrapper {
    let updatedBoard : Board
    let startPosition : BoardCell
    let endPosition : BoardCell
}

struct WallWrapper {
    let updatedBoard : Board
    let topLeft : BoardCell
    let topRight : BoardCell
    let bottomLeft : BoardCell
    let bottomRight : BoardCell

}

protocol BoardFactoryInterface {
    func updateBoard(game : Game) -> Board
    func resolveWall(cellIndex: Int, side: BoardCellSide) -> Wall
    func resolvePawn(cellIndex: Int) -> Pawn
    func getBoardCellsFromPawn(newMove : Pawn) -> PawnWrapper
    func getBoardCellsFromWall(newWall : Wall) -> WallWrapper
    func gameState(game : Game) -> GameStage
}


final class BoardFactory {
    
    private var userInfo : UserInfoInterface?
    private var currentBoard = Board(cells: [], player: Player.startPlayerValue, opponent: Player.startOpponentValue, drawMode: .normal)
    
    init(userInfo : UserInfoInterface?) {
        self.userInfo = userInfo
    }
    
}

extension BoardFactory : BoardFactoryInterface {
    func resolvePawn(cellIndex: Int) -> Pawn {
        return Pawn(position: cellIndex)
    }
    
    func resolveWall(cellIndex: Int, side: BoardCellSide) -> Wall {
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
    
    func gameState(game: Game) -> GameStage {
        let lastMove = game.lastMove
        let currentPlayerId = userInfo?.getUserInfo().userId
        if currentPlayerId != lastMove.playerId {
            if game.gameMoves.count == 2 {
                return .gameAlreadyStarted
            } else {
                return lastMove.moveType == .movePawn ? .opponentMovePawn : .opponentInsertWall
            }
        }
        return .noMove
    }
    
    func updateBoard(game: Game) -> Board {
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
                let currentIndex = (bufferTopDownCell*row)+column
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
        currentBoard = Board(cells: cells, player: currentPlayer, opponent: opponentPlayer, drawMode: drawMode)
        return currentBoard
    }
    
    func getBoardCellsFromPawn(newMove: Pawn) -> PawnWrapper {
        let newPosition = newMove.position
        let newRow = newPosition/10
        let newColumn = newPosition%10
        var cb = currentBoard
        let defaultCell = BoardCell(index: -1, topBorder: .empty, leftBorder: .empty, rightBorder: .empty, bottomBorder: .empty, contentType: .empty)

        for (rowId,_) in cb.cells.enumerated() {
            for (columnId,_) in currentBoard.cells.enumerated() {
                let cell = currentBoard.cells[rowId][columnId]
                if cell.contentType == .opponentPawn {
                    cb.cells[rowId][columnId].contentType = .empty
                    cb.cells[newRow][newColumn].contentType = .playerPawn
                    currentBoard = cb
                    return PawnWrapper(updatedBoard: cb, startPosition: cb.cells[rowId][columnId], endPosition: cb.cells[newRow][newColumn])
                }
            }
        }
        
        return PawnWrapper(updatedBoard: currentBoard, startPosition: defaultCell, endPosition: defaultCell)
    }
    
    func getBoardCellsFromWall(newWall : Wall) -> WallWrapper {
        let wall = newWall
        var cb = currentBoard
        
        let topRightIndex = wall.topRightCell
        let topRightRow = topRightIndex/10
        let topRightColumn = topRightIndex%10
        if wall.orientation == .horizontal {
            cb.cells[topRightRow][topRightColumn].bottomBorder = .wall
        } else {
            cb.cells[topRightRow][topRightColumn].leftBorder = .wall
        }
        let topRightCell = cb.cells[topRightRow][topRightColumn]
        
        let bottomRightIndex = wall.bottomRightCell
        let bottomRightRow = bottomRightIndex/10
        let bottomRightColumn = bottomRightIndex%10
        if wall.orientation == .horizontal {
            cb.cells[bottomRightRow][bottomRightColumn].topBorder = .wall
        } else {
            cb.cells[bottomRightRow][bottomRightColumn].leftBorder = .wall
        }
        let bottomRightCell = cb.cells[bottomRightRow][bottomRightColumn]
        
        let topLeftIndex = wall.topLeftCell
        let topLeftRow = topLeftIndex/10
        let topLeftColumn = topLeftIndex%10
        if wall.orientation == .horizontal {
            cb.cells[topLeftRow][topLeftColumn].bottomBorder = .wall
        } else {
            cb.cells[topLeftRow][topLeftColumn].rightBorder = .wall
        }
        let topLeftCell = cb.cells[topLeftRow][topLeftColumn]
        
        let bottomLeftIndex = wall.bottomLeftCell
        let bottomLeftRow = bottomLeftIndex/10
        let bottomLeftColumn = bottomLeftIndex%10
        if wall.orientation == .horizontal {
            cb.cells[bottomLeftRow][bottomLeftColumn].topBorder = .wall
        } else {
            cb.cells[bottomLeftRow][bottomLeftColumn].rightBorder = .wall
        }
        let bottomLeftCell = cb.cells[bottomLeftRow][bottomLeftColumn]
        
        currentBoard = cb
        return WallWrapper(updatedBoard: cb, topLeft: topLeftCell, topRight: topRightCell, bottomLeft: bottomLeftCell, bottomRight: bottomRightCell)
    }
    
    
}
