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
    func getPlayerName() -> String
    func getBoardFromGame(game : Game) -> Board
    func resolveWall(cellIndex: Int, side: BoardCellSide) -> Wall
    func resolvePawn(cellIndex: Int) -> Pawn
    func getBoardCellsFromPawn(newMove : Pawn, contentType : BoardContentType) -> PawnWrapper
    func getBoardCellsFromWall(newWall : Wall) -> WallWrapper
    func gameState(game : Game) -> GameStage
}


final class BoardFactory {
    
    private var userInfo : UserInfoInterface?
    private var currentBoard = Board(cells: [],
                                     player: Player(name: defaultPlayerName, playerId: defaultPlayerId, pawnPosition: Pawn(position: pawnNilMove), walls: []),
                                     opponent: Player(name: defaultPlayerName, playerId: defaultPlayerId, pawnPosition: Pawn(position: pawnNilMove), walls: []),
                                     drawMode: .normal)
    
    init(userInfo : UserInfoInterface?) {
        self.userInfo = userInfo
    }
    
    
    private func rowColumnWall(drawMode : DrawMode, row : Int, column : Int) -> (Int,Int) {
        if drawMode == .normal {
            return (row, column)
        }
        
        return ((numberOfCellPerRow - 1 - row),(numberOfCellPerRow - 1 - column))
    }
}

extension BoardFactory : BoardFactoryInterface {
    func getPlayerName() -> String {
        return userInfo?.getUserInfo().name ?? defaultPlayerName
    }
    
    func resolvePawn(cellIndex: Int) -> Pawn {
        return Pawn(position: cellIndex)
    }
    
    func resolveWall(cellIndex: Int, side: BoardCellSide) -> Wall {
        let drawMode = currentBoard.drawMode
        var wall = Wall(orientation: .horizontal, topLeftCell: -1, topRightCell: -1, bottomLeftCell: -1, bottomRightCell: -1)

        
        if side == .topSide {
            let topLeftIndex = drawMode == .normal ? cellIndex - bufferTopDownCell : cellIndex - bufferLeftRightCell
            let topRigthIndex = drawMode == .normal ? cellIndex - bufferTopDownCell - bufferLeftRightCell : cellIndex
            let bottomRigthIndex = drawMode == .normal ? cellIndex + bufferLeftRightCell : cellIndex + bufferTopDownCell
            let bottomLeftIndex =  drawMode == .normal ? cellIndex : cellIndex + bufferTopDownCell - bufferLeftRightCell
            wall = Wall(orientation: .horizontal, topLeftCell: topLeftIndex, topRightCell: topRigthIndex, bottomLeftCell: bottomLeftIndex, bottomRightCell: bottomRigthIndex)
        }
        
        if side == .bottomSide {
            let topLeftIndex = drawMode == .normal ? cellIndex : cellIndex - bufferTopDownCell - bufferLeftRightCell
            let topRigthIndex = drawMode == .normal ? cellIndex + bufferLeftRightCell : cellIndex - bufferTopDownCell
            let bottomRigthIndex = drawMode == .normal ? cellIndex + bufferTopDownCell + bufferLeftRightCell : cellIndex
            let bottomLeftIndex =  drawMode == .normal ? cellIndex + bufferTopDownCell : cellIndex - bufferLeftRightCell
            wall = Wall(orientation: .horizontal, topLeftCell: topLeftIndex, topRightCell: topRigthIndex, bottomLeftCell: bottomLeftIndex, bottomRightCell: bottomRigthIndex)
        }
        
        if side == .rightSide {
            let topLeftIndex = drawMode == .normal ? cellIndex + bufferTopDownCell + bufferLeftRightCell : cellIndex - bufferLeftRightCell
            let topRigthIndex = drawMode == .normal ? cellIndex + bufferTopDownCell : cellIndex
            let bottomRigthIndex = drawMode == .normal ? cellIndex + bufferLeftRightCell : cellIndex + bufferTopDownCell
            let bottomLeftIndex = drawMode == .normal ? cellIndex : cellIndex + bufferTopDownCell - bufferLeftRightCell
            wall = Wall(orientation: .vertical, topLeftCell: topLeftIndex, topRightCell: topRigthIndex, bottomLeftCell: bottomLeftIndex, bottomRightCell: bottomRigthIndex)
        }
        
        if side == .leftSide {
            let topLeftIndex = drawMode == .normal ? cellIndex - bufferTopDownCell - bufferLeftRightCell: cellIndex
            let topRigthIndex = drawMode == .normal ? cellIndex - bufferTopDownCell + bufferLeftRightCell : cellIndex + bufferLeftRightCell
            let bottomRigthIndex = drawMode == .normal ? cellIndex : cellIndex + bufferTopDownCell + bufferLeftRightCell
            let bottomLeftIndex = drawMode == .normal ? cellIndex - bufferLeftRightCell : cellIndex + bufferTopDownCell
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
    
    func getBoardFromGame(game: Game) -> Board {
        let currentPlayerId = userInfo?.getUserInfo().userId
        let drawMode: DrawMode = currentPlayerId == game.player1.playerId ? .normal : .reverse
        var currentPlayer = game.player1
        var opponentPlayer = game.player2
        var rows = Array(0..<numberOfCellPerRow)
        var columns  = Array(0..<numberOfCellPerRow)
        
        if drawMode == .reverse {
            rows = rows.reversed()
            columns = columns.reversed()
            currentPlayer = game.player2
            opponentPlayer = game.player1
        }
        
        
        var cells = [[BoardCell]]()
        for row in rows {
            var boardRow = [BoardCell]()
            for column in columns {
                let currentIndex = (bufferTopDownCell*row)+column
                var contentType = BoardContentType.empty
                var topBorder = BorderType.empty
                var leftBorder = BorderType.empty
                var rightBorder = BorderType.empty
                var bottomBorder = BorderType.empty
                
                if topCellsBorder.contains(currentIndex) {
                    if drawMode == .reverse {
                        bottomBorder = .boardBorder
                    } else {
                        topBorder = .boardBorder
                    }
                }
                
                if bottomCellsBorder.contains(currentIndex) {
                    if drawMode == .reverse {
                        topBorder = .boardBorder
                    } else {
                        bottomBorder = .boardBorder
                    }
                }
                
                if rightCellsBorder.contains(currentIndex) {
                    if drawMode == .reverse {
                        leftBorder = .boardBorder
                    } else {
                        rightBorder = .boardBorder
                    }
                }
                
                if leftCellsBorder.contains(currentIndex) {
                    if drawMode == .reverse {
                        rightBorder = .boardBorder
                    } else {
                        leftBorder = .boardBorder
                    }
                }
                
                if currentIndex == currentPlayer.pawnPosition.position {
                    contentType = .playerPawn
                }
                
                if currentIndex == opponentPlayer.pawnPosition.position {
                    contentType = .opponentPawn
                }
                
                let boardCell = BoardCell(index: currentIndex,
                                          topRightBorder: topBorder,
                                          topLeftBorder: topBorder,
                                          bottomLeftBorder: bottomBorder,
                                          bottomRightBorder: bottomBorder,
                                          rightTopBorder: rightBorder,
                                          rightBottomBorder: rightBorder,
                                          leftTopBorder: leftBorder,
                                          leftBottomBorder: leftBorder,
                                          contentType: contentType)
                boardRow.append(boardCell)
                
            }
            cells.append(boardRow)
        }
        currentBoard = Board(cells: cells, player: currentPlayer, opponent: opponentPlayer, drawMode: drawMode)
        return currentBoard
    }
    
    func getBoardCellsFromPawn(newMove: Pawn, contentType : BoardContentType) -> PawnWrapper {
    
        let defaultCell = BoardCell()
       
        let newPosition = newMove.position
        var newBoardCell : BoardCell?
        
        let currentPosition = contentType == .playerPawn ? currentBoard.player.pawnPosition.position : currentBoard.opponent.pawnPosition.position
        var currentBoardCell : BoardCell?
        
        var cb = currentBoard

        for (rowId,_) in cb.cells.enumerated() {
            for (columnId,_) in currentBoard.cells.enumerated() {
                let cell = cb.cells[rowId][columnId]
                
                if cell.index == newPosition {
                    cb.cells[rowId][columnId].contentType = contentType
                    newBoardCell = cb.cells[rowId][columnId]
                }
                
                if cell.index == currentPosition {
                    cb.cells[rowId][columnId].contentType = .empty
                    currentBoardCell = cb.cells[rowId][columnId]
                }
                
                if let nbc = newBoardCell, let cbc = currentBoardCell {
                    if contentType == .playerPawn {
                        cb.player.pawnPosition.position = newPosition
                    } else {
                        cb.opponent.pawnPosition.position = newPosition
                    }
                    currentBoard = cb
                    return PawnWrapper(updatedBoard: cb, startPosition: cbc, endPosition: nbc)
                }
            }
        }
        
        return PawnWrapper(updatedBoard: currentBoard, startPosition: defaultCell, endPosition: defaultCell)
    }
    
    func getBoardCellsFromWall(newWall : Wall) -> WallWrapper {
        let wall = newWall
        var cb = currentBoard
        let mode = currentBoard.drawMode
        
        let topRightIndex = wall.topRightCell
        let topRightRow = topRightIndex/10
        let topRightColumn = topRightIndex%10
        
        
        let (topRightNewRow,topRightNewColumn) = rowColumnWall(drawMode: mode, row: topRightRow, column: topRightColumn)
        if wall.orientation == .horizontal {
            if mode == .normal {
                cb.cells[topRightNewRow][topRightNewColumn].bottomLeftBorder = .wall
            } else {
                cb.cells[topRightNewRow][topRightNewColumn].topRightBorder = .wall
            }
        } else {
            if mode == .normal {
                cb.cells[topRightNewRow][topRightNewColumn].leftBottomBorder = .wall
            } else {
                cb.cells[topRightNewRow][topRightNewColumn].rightTopBorder = .wall
            }
        }
        let topRightCell = cb.cells[topRightNewRow][topRightNewColumn]
        
        
        
        let bottomRightIndex = wall.bottomRightCell
        let bottomRightRow = bottomRightIndex/10
        let bottomRightColumn = bottomRightIndex%10
        
        let (bottomRightNewRow,bottomRightNewColumn) = rowColumnWall(drawMode: mode, row: bottomRightRow, column: bottomRightColumn)
        if wall.orientation == .horizontal {
            if mode == .normal {
                cb.cells[bottomRightNewRow][bottomRightNewColumn].topLeftBorder = .wall
            } else {
                cb.cells[bottomRightNewRow][bottomRightNewColumn].bottomRightBorder = .wall
            }
        } else {
            if mode == .normal {
                cb.cells[bottomRightNewRow][bottomRightNewColumn].leftTopBorder = .wall
            } else {
                cb.cells[bottomRightNewRow][bottomRightNewColumn].rightBottomBorder = .wall
            }
        }
        let bottomRightCell = cb.cells[bottomRightNewRow][bottomRightNewColumn]
        
        
        
        let topLeftIndex = wall.topLeftCell
        let topLeftRow = topLeftIndex/10
        let topLeftColumn = topLeftIndex%10
        
        let (topLeftNewRow,topLeftNewColumn) = rowColumnWall(drawMode: mode, row: topLeftRow, column: topLeftColumn)
        if wall.orientation == .horizontal {
            if mode == .normal {
                cb.cells[topLeftNewRow][topLeftNewColumn].bottomRightBorder = .wall
            } else {
                cb.cells[topLeftNewRow][topLeftNewColumn].topLeftBorder = .wall
            }
        } else {
            if mode == .normal {
                cb.cells[topLeftNewRow][topLeftNewColumn].rightBottomBorder = .wall
            } else {
                cb.cells[topLeftNewRow][topLeftNewColumn].leftTopBorder = .wall
            }
        }
        let topLeftCell = cb.cells[topLeftNewRow][topLeftNewColumn]
        
        
        
        let bottomLeftIndex = wall.bottomLeftCell
        let bottomLeftRow = bottomLeftIndex/10
        let bottomLeftColumn = bottomLeftIndex%10
        
        
        let (bottomLeftNewRow,bottomLeftNewColumn) = rowColumnWall(drawMode: mode, row: bottomLeftRow, column: bottomLeftColumn)
        if wall.orientation == .horizontal {
            if mode == .normal {
                cb.cells[bottomLeftNewRow][bottomLeftNewColumn].topRightBorder = .wall
            } else {
                cb.cells[bottomLeftNewRow][bottomLeftNewColumn].bottomLeftBorder = .wall
            }
        } else {
            if mode == .normal {
                cb.cells[bottomLeftNewRow][bottomLeftNewColumn].rightTopBorder = .wall
            } else {
                cb.cells[bottomLeftNewRow][bottomLeftNewColumn].leftBottomBorder = .wall
            }
        }
        let bottomLeftCell = cb.cells[bottomLeftNewRow][bottomLeftNewColumn]
        
        currentBoard = cb
        return WallWrapper(updatedBoard: cb, topLeft: topLeftCell, topRight: topRightCell, bottomLeft: bottomLeftCell, bottomRight: bottomRightCell)
    }
    
    
}

extension BoardFactory : GameSettingsProtocol {
    func getWinningCells(mode: PlayerType) -> [Pawn] {
        return mode == .player1 ? topCellsBorder.map({ Pawn(position: $0 )}) : bottomCellsBorder.map({ Pawn(position: $0 )})
    }
    
    func nextTopPosition(position: Int, mode : PlayerType, walls : [Wall]) -> Int? {
        if mode == .player1 {
            if walls.contains(where: { ($0.bottomLeftCell == position || $0.bottomRightCell == position) && $0.orientation == .horizontal }) == false {
                return position - bufferTopDownCell
            }
        } else {
            if walls.contains(where: { ($0.topLeftCell == position || $0.topRightCell == position) && $0.orientation == .horizontal }) == false {
                return position + bufferTopDownCell
            }
        }
        return nil
    }
    
    func nextBottomPosition(position: Int, mode : PlayerType, walls : [Wall]) -> Int? {
        if mode == .player1 {
            if walls.contains(where: { ($0.topLeftCell == position || $0.topRightCell == position) && $0.orientation == .horizontal }) == false {
                return position + bufferTopDownCell
            }
        } else {
            if walls.contains(where: { ($0.bottomLeftCell == position || $0.bottomRightCell == position) && $0.orientation == .horizontal }) == false {
                return position - bufferTopDownCell
            }
        }
        
        return nil
    }
    
    func nextRightPosition(position: Int, mode : PlayerType, walls : [Wall]) -> Int? {
        if mode == .player1 {
            if walls.contains(where: { ($0.topLeftCell == position || $0.bottomLeftCell == position) && $0.orientation == .vertical }) == false {
                return position + bufferLeftRightCell
            }
        } else {
            if walls.contains(where: { ($0.topRightCell == position || $0.bottomRightCell == position) && $0.orientation == .vertical }) == false {
                return position - bufferLeftRightCell
            }
        }
        
        return nil
    }
    
    func nextLeftPosition(position: Int, mode : PlayerType, walls : [Wall]) -> Int? {
        if mode == .player1 {
            if walls.contains(where: { ($0.topRightCell == position || $0.bottomRightCell == position) && $0.orientation == .vertical }) == false {
                return position - bufferLeftRightCell
            }
        } else {
            if walls.contains(where: { ($0.topLeftCell == position || $0.bottomLeftCell == position) && $0.orientation == .vertical }) == false {
                return position + bufferLeftRightCell
            }
        }
        
        return nil
    }
    

    
    var startWall: Wall {
        return Wall(orientation: .horizontal, topLeftCell: -1, topRightCell: -1, bottomLeftCell: -1, bottomRightCell: -1)

    }
    
    var defaultGame: Game {
        let defaultPlayer1 = Player(name: defaultPlayerName, playerId: defaultPlayerId, pawnPosition: Pawn(position: startPlayer1PawnPosition), walls: [])
        let defaultPlayer2 = Player(name: defaultPlayerName, playerId: defaultPlayerId, pawnPosition: Pawn(position: startPlayer2PawnPosition), walls: [])
        let defaultWall = Wall(orientation: .horizontal, topLeftCell: -1, topRightCell: -1, bottomLeftCell: -1, bottomRightCell: -1)
        let defaultMove = Move(playerId: defaultPlayerId, pawnMove: Pawn(position: pawnNilMove), wallMove: defaultWall, moveType: .movePawn)

        return Game(created: 0, state: .waiting, player1: defaultPlayer1, player2: defaultPlayer2, lastMove: defaultMove, gameMoves: [defaultMove])
    }
    
    func outOfBoard(wall: Wall) -> Bool {
        
        return wall.topLeftCell < 0 || wall.topLeftCell > 89 || wall.topRightCell < 0 || wall.topRightCell > 89 ||
        wall.bottomLeftCell < 0 || wall.bottomLeftCell > 89 || wall.bottomRightCell < 0 || wall.bottomRightCell > 89 ||
        leftRightBorder.contains(wall.topLeftCell) || leftRightBorder.contains(wall.topRightCell) || leftRightBorder.contains(wall.bottomLeftCell) || leftRightBorder.contains(wall.bottomRightCell)
    }
    
    func outOfBoard(pawn: Pawn) -> Bool {
        let position = pawn.position
        return position < 0 || position > 89 || leftRightBorder.contains(position)
    }
    
    var startPlayerPosition: Pawn {
        return Pawn(position: startPlayer1PawnPosition)
    }
    
    var startOpponentPosition: Pawn {
        return Pawn(position: startPlayer2PawnPosition)
    }
}
