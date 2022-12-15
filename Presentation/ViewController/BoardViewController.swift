//
//  BoardViewController.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import UIKit
import Combine

class BoardViewController: UIViewController {

    @IBOutlet private var boardView : UIView!
    
    private var viewModel : BoardViewModelProtocol?
    private var listener : GameInputViewModelProtocol?
    private var board : Board = Board(cells: [[]], player: Player.startPlayerValue, opponent: Player.startOpponentValue, drawMode: .normal)
    private var allowedCells : [Pawn] = []
    
    private var subscribers: [AnyCancellable] = []

    private var indexPawn = 0
    private var indexWall = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        initBoard()
    }

    
    init(viewModel: BoardViewModelProtocol,
         listener : GameInputViewModelProtocol?) {
        super.init(nibName: String(describing: "BoardViewController"), bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupObserver(){
        listener?.gameEventListener.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] board in
            guard let self = self else { return }
           
            print("BoardViewController - board updated")
            
        }).store(in: &subscribers)
    }

    private func initBoard(){
        let width = Int(boardView.frame.width)
        let cellWidth = Int(width/numberOfCellPerRow)
        let cellHeight = cellWidth

        
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
    
    private func updateBoardPawnCells(allowed : Bool){
        for c in allowedCells {
            if let pawnCell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == c.position  }).first as? BoardCellView {
                pawnCell.updateColor(allowed: allowed)
            }
        }
    }

    
}


extension BoardViewController : BoardCellDelegate {
    func tapCell(index: Int) {
        if index == board.player.pawnPosition.position {
            if allowedCells.count > 0 {
                updateBoardPawnCells(allowed: false)
                allowedCells.removeAll()
            } else {
                allowedCells = viewModel?.allowedPawnMoves() ?? []
                updateBoardPawnCells(allowed: false)
            }
            
        } else {
            if allowedCells.contains(where: { $0.position == index}){
                viewModel?.movePawn(pawn: Pawn(position: index))
            }
        }
    }
    
    func tapWall(index: Int, side: BoardCellSide) {
        if let wall = listener?.getWall(cellIndex: index, side: side) {
            viewModel?.insertWall(wall: wall)
        }
    }

}
