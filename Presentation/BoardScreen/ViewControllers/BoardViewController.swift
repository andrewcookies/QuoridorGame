//
//  BoardViewController.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import UIKit
import Combine

protocol BoardViewControllerProtocol {
    func updateOpponentPawnOnBoard(start : BoardCell, destination : BoardCell)
    func updatePawnOnBoard(start : BoardCell, destination : BoardCell)
    func updateOpponentWallOnBoard(topRight : BoardCell, topLeft : BoardCell, bottomRight : BoardCell, bottomLeft : BoardCell)
    func updateWallOnBoard(topRight : BoardCell, topLeft : BoardCell, bottomRight : BoardCell, bottomLeft : BoardCell)
    func initBoard(board : Board)
    func handelEvent(gameEvent : GameEvent)
}

enum GameAction {
    case wallSelected
    case pawnSelected
    case chooseMove
    case searchMatch
    case waitingForOpponant
    case loadYourMove
}

class BoardViewController: UIViewController {

    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var optionScreenHeight: NSLayoutConstraint!
    @IBOutlet weak var upperScreenHeight: NSLayoutConstraint!
    @IBOutlet weak var middleScreenHeight: NSLayoutConstraint!
    
    @IBOutlet weak var boardContainer: UIView!
    @IBOutlet weak var playerWallContaier: UIView!
    @IBOutlet weak var playerInfoView: PlayerInfoView!
    @IBOutlet weak var opponentInfoView: UIView!
    
    
    @IBOutlet private var boardView : UIView!
    
    private var viewModel : BoardViewModelProtocol?
    private var allowedCells : [Pawn] = []
    
    private var subscribers: [AnyCancellable] = []

    private var indexPawn = 0
    private var indexWall = 0
    
    private var playerAvailableWalls : [WallView] = []
    
    
    
    private var gameAction : GameAction = .chooseMove {
        didSet {
            GameLog.shared.debug(message: "current game action \(gameAction)", className: "BoardViewController")
            updateInfoBoxes(state: gameAction)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel?.startMatch()
        
        
    }
    
    private func startLoading(isLoading : Bool){
        if isLoading {
            loadingView.isHidden = false
            loadingSpinner.startAnimating()
        } else {
            loadingView.isHidden = true
            loadingSpinner.stopAnimating()
        }
    }

    
    init(viewModel: BoardViewModelProtocol) {
        super.init(nibName: String(describing: "BoardViewController"), bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDimensions(){
        
        let screenHeight = rootView.frame.height

        let boardWidth = boardView.frame.width//screenWidth
        let wallHeight = (boardWidth / CGFloat(numberOfCellPerRow))*2
        let boardHeight = boardWidth + wallHeight
        
        let optionHeight = CGFloat(25)
        
        let infoHeight = screenHeight*0.10
        
        optionScreenHeight.constant = optionHeight
        //upperScreenHeight.constant = infoHeight
        //middleScreenHeight.constant = boardHeight
    }
    
    private func setupUI(){
        
       // setDimensions()
        
        opponentInfoView.layer.cornerRadius = 4
        opponentInfoView.clipsToBounds = true

        playerInfoView.layer.cornerRadius = 4
        playerInfoView.clipsToBounds = true

        boardContainer.backgroundColor = colorCell
        boardContainer.layer.cornerRadius = 4
        boardContainer.clipsToBounds = true
        
        boardView.backgroundColor = colorBorder
        playerWallContaier.backgroundColor = colorBorder

        loadingView.backgroundColor = mainColor
        
        //setup players dashboard
        if let playerView = PlayerInfoView.getView() as? PlayerInfoView {
            playerView.frame = CGRect(x: 0, y: 0, width: playerInfoView.frame.width, height: playerInfoView.frame.height)
            playerView.setup(name: viewModel?.currentPlayerName ?? "", player : .player1)
            playerView.actionState = .searchMatch
            playerView.delegate = self
            playerInfoView.addSubview(playerView)
        }
        
        if let opponentView = PlayerInfoView.getView() as? PlayerInfoView {
            opponentView.frame = CGRect(x: 0, y: 0, width: opponentInfoView.frame.width, height: opponentInfoView.frame.height)
            opponentView.setup(name: defaultPlayerName, player : .player2)
            opponentView.actionState = .searchMatch
            opponentView.delegate = self
            opponentInfoView.addSubview(opponentView)
        }

        
    }
    
    private func updateBoardAllowedPawnCells(allowed : Bool){
        for c in allowedCells {
            if let pawnCell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == c.position  }).first as? BoardCellView {
                pawnCell.updateColor(allowed: allowed)
            }
        }
    }
    
    private func updateWallPosition(topRight: BoardCell, topLeft: BoardCell, bottomRight: BoardCell, bottomLeft: BoardCell) {
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
    
    private func getPopup(type : PopupType) -> QPopupViewController {
        let vc = QPopupViewController()
        vc.type = type
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    private func updateInfoBoxes(state : GameAction){
        if let view = opponentInfoView.subviews.first as? PlayerInfoView {
            view.actionState = state
        }
        
        if let view = playerInfoView.subviews.first as? PlayerInfoView {
            view.actionState = state
        }
        
    }
    
    private func updatePawnPosition(start: BoardCell, destination: BoardCell) {
        if let cell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == start.index  }).first as? BoardCellView,  let newCell = boardView.subviews.filter({ ($0 as? BoardCellView)?.getIndex() == destination.index }).first as? BoardCellView {
            cell.setup(cell: start)
            newCell.setup(cell: destination)
        }
    }
    
    //MARK: Actions
    
    @IBAction func infoTapped(_ sender: UIButton) {
        let vc = getPopup(type : .rules)
        self.present(vc, animated: true)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        let vc = getPopup(type : .quitMatch)
        self.present(vc, animated: true)
    }

}

extension BoardViewController : PopupDelegate {
    func acceptOpponentQuitMatch() {
        viewModel?.close()
    }
    
    func acceptError() {
        viewModel?.close()
    }
    
    func acceptQuitMatch() {
        viewModel?.quitMatch()
    }
    
    func acceptLostMatch() {
        viewModel?.close()
    }
    
    func acceptWonMatch() {
        viewModel?.close()
    }
    
}


extension BoardViewController : BoardViewControllerProtocol {
    func handelEvent(gameEvent: GameEvent) {
        switch gameEvent {
        case .noEvent, .noWall, . invalidPawn, .invalidWall:
            //Everything is all right, no error
            break
            
            
        case .waiting:
            gameAction = .loadYourMove
            
        case .waitingOpponentMove:
            gameAction = .waitingForOpponant

        case .matchWon:
            self.present(getPopup(type: .wonMatch), animated: true)
            
        case .matchLost:
            self.present(getPopup(type: .lostMatch), animated: true)
            
        case .error:
            self.present(getPopup(type: .genericError), animated: true)
            
            
        case .searchingOpponents:
            gameAction = .searchMatch
            startLoading(isLoading: true)
            
        case .endGame:
            viewModel?.close()
            
        case .opponentQuitMatch:
            self.present(getPopup(type: .opponentQuitMatch), animated: true)
            
        case .ringFound:
            self.present(getPopup(type: .ringWallFound), animated: true)
        }
    }
    
    func initBoard(board: Board) {
        let width = Int(boardView.frame.width)
        let cellWidth = Int(width/numberOfCellPerRow)
        
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
        
        
        let wallWidth = Int(Double(cellWidth) * 0.10 * 2)
        let wallHeight = Int(cellWidth*2 - wallWidth*2)
        let sectionHeight = Int(playerWallContaier.frame.height)
    
        for rowId in 0...numberWallPerPlayer {
            let v = UIView(frame: CGRect(x: ((rowId*cellWidth) + 10 - (wallWidth/2)), y: 0, width: wallWidth, height: sectionHeight))
            v.backgroundColor = colorEmptyWall
            
            
            let wall = WallView(frame: CGRect(x: 0, y: 10, width: wallWidth, height: wallHeight))
            wall.setup(state: .normal)
            wall.wallIndex = rowId+wallViiewConst
            wall.delegate = self
            
            v.addSubview(wall)
            playerAvailableWalls.append(wall)
            playerWallContaier.addSubview(v)
            playerWallContaier.backgroundColor = colorCell
        }
        
        gameAction = .chooseMove
        startLoading(isLoading: false)
    }
    
    func updatePawnOnBoard(start: BoardCell, destination: BoardCell) {
        updatePawnPosition(start: start, destination: destination)
        gameAction = .waitingForOpponant
    }
    
    func updateOpponentPawnOnBoard(start: BoardCell, destination: BoardCell) {
        updatePawnPosition(start: start, destination: destination)
        gameAction = .chooseMove
    }
    
    func updateWallOnBoard(topRight: BoardCell, topLeft: BoardCell, bottomRight: BoardCell, bottomLeft: BoardCell) {
        
        updateWallPosition(topRight: topRight, topLeft: topLeft, bottomRight: bottomRight, bottomLeft: bottomLeft)
        
        if let wall = playerAvailableWalls.filter({ $0.currentState == .normal }).first {
            wall.removeFromSuperview()
            playerAvailableWalls.forEach({ $0.setup(state: .normal)})
        }
        
        gameAction = .chooseMove
    }
    
    func updateOpponentWallOnBoard(topRight: BoardCell, topLeft: BoardCell, bottomRight: BoardCell, bottomLeft: BoardCell) {
        updateWallPosition(topRight: topRight, topLeft: topLeft, bottomRight: bottomRight, bottomLeft: bottomLeft)
        gameAction = .waitingForOpponant
    }
}

extension BoardViewController : BoardCellDelegate {
    func tapCell(index: Int) {
        if index == viewModel?.currentPawnPosition {
            if gameAction == .pawnSelected {
                updateBoardAllowedPawnCells(allowed: false)
                allowedCells.removeAll()
                gameAction = .chooseMove
                
            } else if gameAction == .chooseMove {
                allowedCells = viewModel?.allowedPawnMoves(cellIndex: index) ?? []
                updateBoardAllowedPawnCells(allowed: true)
                gameAction = .pawnSelected
            }
            
        } else {
            if allowedCells.contains(where: { $0.position == index}){
                updateBoardAllowedPawnCells(allowed: false)
                allowedCells.removeAll()
                viewModel?.movePawn(cellIndex: index)
                gameAction = .chooseMove
            }
        }
    }
    
    func tapWall(index: Int, side: BoardCellSide) {
        if gameAction == .wallSelected {
            viewModel?.insertWall(cellIndex: index, side: side)
        }
    }

}


extension BoardViewController : WallViewDelegate {
    func tapWallView(wallIndex: Int) {
        if gameAction == .chooseMove {
            for w in playerAvailableWalls {
                if w.wallIndex != wallIndex {
                    w.setup(state: .disabled)
                }
            }
            gameAction = .wallSelected
            
        } else if gameAction == .wallSelected {
            if let wall = playerAvailableWalls.filter({ $0.wallIndex == wallIndex}).first {
                if wall.currentState == .normal {
                    playerAvailableWalls.forEach({ $0.setup(state: .normal)})
                    gameAction = .chooseMove
                }
            }
        }
    }
}

extension BoardViewController : PlayerInfoViewDelegate {
    
}
