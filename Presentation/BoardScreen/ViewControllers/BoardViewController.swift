//
//  BoardViewController.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import UIKit
import Combine

protocol BoardViewControllerProtocol {
    func updateOpponentPawn(start : BoardCell, destination : BoardCell)
    func updateWall(topRight : BoardCell, topLeft : BoardCell, bottomRight : BoardCell, bottomLeft : BoardCell)
    func initBoard(board : Board)
    func handelEvent(gameEvent : GameEvent)
}

class BoardViewController: UIViewController {

    @IBOutlet private var boardView : UIView!
    
    private var viewModel : BoardViewModelProtocol?
    private var currentPosition : Pawn = Pawn(position: startPlayer1PawnPosition)
    private var allowedCells : [Pawn] = []
    
    private var subscribers: [AnyCancellable] = []

    private var indexPawn = 0
    private var indexWall = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.startMatch()
    }

    
    init(viewModel: BoardViewModelProtocol) {
        super.init(nibName: String(describing: "BoardViewController"), bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateBoardAllowedPawnCells(allowed : Bool){
        for c in allowedCells {
            if let pawnCell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == c.position  }).first as? BoardCellView {
                pawnCell.updateColor(allowed: allowed)
            }
        }
    }

}

extension BoardViewController : BoardViewControllerProtocol {
    func handelEvent(gameEvent: GameEvent) {
        switch gameEvent {
        case .waiting:
            break
        case .waitingOpponentMove:
            break
        case .matchWon:
            break
        case .matchLost:
            break
        case .updateBoard:
            break
        case .error:
            break
        case .invalidWall:
            break
        case .noWall:
            break
        case .invalidPawn:
            break
        case .noEvent:
            break
        case .searchingOpponents:
            break
        case .endGame:
            break
        case .joiningMatch:
            break
        }
    }
    
    func initBoard(board: Board) {
        let width = Int(boardView.frame.width)
        let cellWidth = Int(width/numberOfCellPerRow)

        currentPosition = board.player.pawnPosition
        
        for (rowId,cellsRow) in board.cells.enumerated() {
            //let cellRow = board.cells[rowIndex]
            for (columnId,cell) in cellsRow.enumerated() {
               // let cell = cellRow[columnIndex]
                if let v = BoardCellView.getView() as? BoardCellView {
                    v.frame = CGRect(x: columnId*cellWidth, y: rowId*cellWidth, width: cellWidth, height: cellWidth)
                    v.setup(cell: cell)
                    v.delegate = self
                    boardView.addSubview(v)
                }
            }
        }
    }
    
    func updateOpponentPawn(start: BoardCell, destination: BoardCell) {
        if let opponentCell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == start.index  }).first as? BoardCellView,  let newOpponentCell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == destination.index }).first as? BoardCellView {
            opponentCell.setup(cell: start)
            newOpponentCell.setup(cell: destination)
            currentPosition = Pawn(position: destination.index)
        }
    }
    
    func updateWall(topRight: BoardCell, topLeft: BoardCell, bottomRight: BoardCell, bottomLeft: BoardCell) {
        if let cell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == topRight.index  }).first as? BoardCellView {
            cell.setup(cell: topRight)
        }
        if let cell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == topLeft.index  }).first as? BoardCellView {
            cell.setup(cell: topLeft)
        }
        if let cell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == bottomRight.index  }).first as? BoardCellView {
            cell.setup(cell: bottomRight)
        }
        if let cell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == bottomLeft.index  }).first as? BoardCellView {
            cell.setup(cell: bottomLeft)
        }
        
    }
}

extension BoardViewController : BoardCellDelegate {
    func tapCell(index: Int) {
        if index == currentPosition.position {
            if allowedCells.count > 0 {
                updateBoardAllowedPawnCells(allowed: false)
                allowedCells.removeAll()
            } else {
                allowedCells = viewModel?.allowedPawnMoves() ?? []
                updateBoardAllowedPawnCells(allowed: true)
            }
            
        } else {
            if allowedCells.contains(where: { $0.position == index}){
                updateBoardAllowedPawnCells(allowed: false)
                allowedCells.removeAll()
                viewModel?.movePawn(cellIndex: index)
            }
        }
    }
    
    func tapWall(index: Int, side: BoardCellSide) {
        if allowedCells.count == 0 {
            viewModel?.insertWall(cellIndex: index, side: side)
        }
    }

}
