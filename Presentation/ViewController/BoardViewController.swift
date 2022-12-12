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
    private var allowedCells : [Int] = []
    
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
        let playerPosition = board.player.pawnPosition.position
        let opponentPosition = board.opponent.pawnPosition.position
        
        for row in 0..<numberOfCellPerRow {
            for column in 0..<numberOfCellPerRow{
                let currentIndex = row+column
                let v = BoardCellView(frame: CGRect(x: column*cellWidth, y: row, width: cellWidth, height: cellWidth))
                
                var cellType = BoardCellType.normalCell
                if currentIndex == playerPosition {
                    cellType = .playerCell
                } else if currentIndex == opponentPosition {
                    cellType = .opponentCell
                } else if allowedCells.contains(currentIndex) {
                    cellType = .allowedCell
                }
                
                let walls = totalWalls.filter({ $0.bottomLeftCell == currentIndex || $0.bottomRightCell == currentIndex || $0.topLeftCell == currentIndex || $0.topRightCell == currentIndex })
                
                
                v.setup(index: currentIndex, mode: board.drawMode, type: cellType, delegate: self, walls: walls)
                boardView.addSubview(v)

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

    
    @IBAction func searchMatch(_ sender: UIButton) {
        viewModel?.initializeMatch()
    }
    
    @IBAction func putWall(_ sender: UIButton) {
        indexPawn += 1
        viewModel?.movePawn(index: indexPawn)
    }
    
    @IBAction func insertWall(_ sender: UIButton) {
        indexWall += 1
        viewModel?.insertWall(index: indexWall)
    }
    
    @IBAction func quit(_ sender: UIButton) {
        viewModel?.quitMatch()
    }
    
}


extension BoardViewController : BoardCellDelegate {
    
}
