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
    private var board : UIBoard = UIBoard(drawMode: .normal, player: Player.startPlayerValue, opponent: Player.startOpponentValue)
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
        
        for row in 0..<numberOfCellPerRow {
            for column in 0..<numberOfCellPerRow{
                let currentIndex = row+column
                let currentPawn = Pawn(position: currentIndex)
                let v = BoardCellView(frame: CGRect(x: column*cellWidth, y: row, width: cellWidth, height: cellWidth))
                
                var cellType = BoardCellType.normalCell
                if currentPawn == playerPosition {
                    cellType = .playerCell
                } else if currentPawn == opponentPosition {
                    cellType = .opponentCell
                } else if allowedCells.contains(where:{ currentPawn == $0 }) {
                    cellType = .allowedCell
                }
                
                let walls = totalWalls.filter({ $0.bottomLeftCell == currentIndex || $0.bottomRightCell == currentIndex || $0.topLeftCell == currentIndex || $0.topRightCell == currentIndex })
                
                
                v.setup(index: currentIndex, mode: board.drawMode, type: cellType, delegate: self, walls: walls)
                boardView.addSubview(v)
                boardViewCells.append(v)

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.

     // Pass the selected object to the new view controller.
    }
    */

    
}


extension BoardViewController : BoardCellDelegate {
    func tapCell(pawnCell: Pawn) {
        if pawnCell == board.player.pawnPosition {
            if allowedCells.count > 0 {
                updateBoardPawnCells(allowed: false)
                allowedCells = []
            } else {
                allowedCells = viewModel?.allowedPawnMoves() ?? []
                updateBoardPawnCells(allowed: false)
            }
            
        } else {
            if allowedCells.contains(where: { $0 == pawnCell}){
                viewModel?.movePawn(pawn: pawnCell)
            }
        }
    }
    
    func tapWall(wall: Wall) {
        viewModel?.insertWall(wall: wall)
    }
}
