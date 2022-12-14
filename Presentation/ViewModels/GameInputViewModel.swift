//
//  MatchmakingViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 04/12/22.
//

import Foundation
import Combine

protocol GameInputViewModelProtocol {
    var gameEventListener : Published<Board>.Publisher { get }
}


final class GameInputViewModel {
    @Published private var currentBoard : Board
    private var userInfo : UserInfoInterface?
    
    init(userInfo : UserInfoInterface?){
        self.userInfo = userInfo
        currentBoard = Board(cells: [[]], player: Player.startPlayerValue, opponent: Player.startOpponentValue, drawMode: .normal)
    }
    
    private func convertGameToBoard(game : Game) -> Board {
        
        let currentPlayerId = userInfo?.getUserInfo().userId
        let totalWalls = game.getTotalWalls()
        var cells = [[BoardCell]]()
        var drawMode = DrawMode.normal
        var currentPlayer = game.player1
        var opponentPlayer = game.player2
        
        if currentPlayerId == game.player2.playerId {
            drawMode = DrawMode.reverse
            currentPlayer = game.player2
            opponentPlayer = game.player1
        }

        
        for row in 0..<numberOfCellPerRow {
            var boardRow = [BoardCell]()
            for column in 0..<numberOfCellPerRow {
                let currentIndex = row+column
                var topBorder = BorderType.empty
                var leftBorder = BorderType.empty
                var rightBorder = BorderType.empty
                var bottomBorder = BorderType.empty
                var contentType = ContentType.empty
                
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
                
                
                for w in totalWalls {
                    if w.orientation == .horizontal {
                        if currentIndex == w.topLeftCell || currentIndex == w.topRightCell {
                            bottomBorder = .wall
                        }
                        
                        if currentIndex == w.bottomLeftCell || currentIndex == w.bottomRightCell {
                            topBorder = .wall
                        }
                            
                    } else {
                        if currentIndex == w.topLeftCell || currentIndex == w.bottomLeftCell {
                            rightBorder = .wall
                        }
                        
                        if currentIndex == w.topRightCell || currentIndex == w.bottomRightCell {
                            leftBorder = .wall
                        }
                        
                    }
                }
                
                if currentIndex == currentPlayer.pawnPosition.position {
                    contentType = .playerPawn
                }
                
                if currentIndex == opponentPlayer.pawnPosition.position {
                    contentType = .opponentPawn
                }
                
                
                let cell = BoardCell(index: currentIndex, topBorder: topBorder, leftBorder: leftBorder, rightBorder: rightBorder, bottomBorder: bottomBorder, contentType: contentType)
                boardRow.append(cell)
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
        let board = convertGameToBoard(game: game)
        currentBoard = board
    }
    
}

extension GameInputViewModel : GameInputViewModelProtocol {
    var gameEventListener: Published<Board>.Publisher {
        $currentBoard
    }
}
