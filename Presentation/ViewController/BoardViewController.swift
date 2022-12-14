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
    private var boardViewCells : [BoardCellView] = []
    
    private var subscribers: [AnyCancellable] = []

    private var indexPawn = 0
    private var indexWall = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        setupBoard()
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

    private func setupBoard(){
        let width = Int(boardView.frame.width)
        let cellWidth = Int(width/numberOfCellPerRow)
        let cellHeight = cellWidth
        let totalWalls = board.player.walls + board.opponent.walls
        let playerPosition = board.player.pawnPosition
        let opponentPosition = board.opponent.pawnPosition
        
        let rowSequence = board.drawMode == .normal ? [8,7,6,5,4,3,2,1,0] : [0,1,2,3,4,5,6,7,8]
        let columnSequence = board.drawMode == .normal ?  [0,1,2,3,4,5,6,7,8] : [8,7,6,5,4,3,2,1,0]
        //TODO:
        for rowIndex in rowSequence {
            let cellRow = board.cells[rowIndex]
            
            for columnIndex in columnSequence {
                let cell = cellRow[columnIndex]
                
               // let v = BoardCellView(frame: CGRect(x: column*cellWidth, y: row, width: cellWidth, height: cellWidth))
              //  boardView.addSubview(v)
               // boardViewCells.append(v)

            }
        }
                
    }
    
    private func updateBoardPawnCells(allowed : Bool){
        for c in allowedCells {
            if let pawnCell = boardViewCells.filter({ $0.getIndex() == c.position }).first{
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
                allowedCells = []
            } else {
                allowedCells = viewModel?.allowedPawnMoves() ?? []
                updateBoardPawnCells(allowed: false)
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
