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
    private var board : Board = Board(cells: [[]], player: Player.startPlayerValue, opponent: Player.startOpponentValue, drawMode: .normal)
    private var allowedCells : [Pawn] = []
    
    private var subscribers: [AnyCancellable] = []

    private var indexPawn = 0
    private var indexWall = 0

    override func viewDidLoad() {
        super.viewDidLoad()
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
        }
    }
    
    func initBoard(board: Board) {
        let width = Int(boardView.frame.width)
        let cellWidth = Int(width/numberOfCellPerRow)

        
        let rowSequence = (0..<numberOfCellPerRow)
        let columnSequence = (0..<numberOfCellPerRow)
        
        for rowIndex in rowSequence {
            let cellRow = board.cells[rowIndex]
            for columnIndex in columnSequence {
                let cell = cellRow[columnIndex]
                let v = BoardCellView(frame: CGRect(x: columnIndex*cellWidth, y: rowIndex, width: cellWidth, height: cellWidth))
                v.setup(cell: cell)
                boardView.addSubview(v)
            }
        }
    }
    
    func updateOpponentPawn(start: BoardCell, destination: BoardCell) {
        if let opponentCell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == start.index  }).first as? BoardCellView {
            opponentCell.setup(cell: start)
        }
        if let newOpponentCell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == destination.index }).first as? BoardCellView {
            newOpponentCell.setup(cell: destination)
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
        if index == board.player.pawnPosition.position {
            if allowedCells.count > 0 {
                updateBoardAllowedPawnCells(allowed: false)
                allowedCells.removeAll()
            } else {
                allowedCells = viewModel?.allowedPawnMoves() ?? []
                updateBoardAllowedPawnCells(allowed: false)
            }
            
        } else {
            if allowedCells.contains(where: { $0.position == index}){
                viewModel?.movePawn(cellIndex: index)
            }
        }
    }
    
    func tapWall(index: Int, side: BoardCellSide) {
        viewModel?.insertWall(cellIndex: index, side: side)
    }

}
