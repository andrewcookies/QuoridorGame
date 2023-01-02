//
//  BoardCellView.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 12/12/22.
//

import UIKit
protocol BoardCellDelegate : AnyObject {
    func tapCell(index : Int)
    func tapWall(index: Int, side: BoardCellSide)
}

enum BoardCellSide {
    case topSide
    case leftSide
    case rightSide
    case bottomSide
}

class BoardCellView: UIView {
    
    @IBOutlet weak var tmpLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var topWallView: UIView!
    @IBOutlet weak var leftWallView: UIView!
    @IBOutlet weak var bottomWallView: UIView!
    @IBOutlet weak var rightWallView: UIView!
    
    private var cellIndex : Int = -1
    private var contentType : BoardContentType = .empty
    
    weak var delegate : BoardCellDelegate?
    
    
    static func getView() -> UIView? {
        guard let _view = Bundle.main.loadNibNamed("BoardCellView", owner: self, options: nil)?.first,
              let view = _view as? BoardCellView
        else { return nil }
        return view
    }
    
    override  func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func getIndex() -> Int {
        return cellIndex
    }
    
    func updateColor(allowed : Bool){
        cellView.backgroundColor = allowed ? colorAllowedCell : colorCell
    }
    
    func setup(cell : BoardCell){
        
        
        cellIndex = cell.index
        contentType = cell.contentType
        
        switch contentType {
        case .playerPawn:
            cellView.backgroundColor = colorPlayerPawn
            
        case .opponentPawn:
            cellView.backgroundColor = colorOpponentPawn
            
        case .allowed:
            cellView.backgroundColor = colorAllowedCell
            
        case .empty:
            cellView.backgroundColor = colorCell
        }
        
        topWallView.backgroundColor = getColor(type: cell.topBorder)
        
        if cell.topBorder == .wall {
            topWallView.layer.zPosition = 1
        } else if cell.topBorder == .boardBorder {
            topWallView.layer.zPosition = 2
        }
        
        bottomWallView.backgroundColor = getColor(type: cell.bottomBorder)
        if cell.bottomBorder == .wall  {
            bottomWallView.layer.zPosition = 1
        } else if cell.bottomBorder == .boardBorder {
            bottomWallView.layer.zPosition = 2
        }
        
        rightWallView.backgroundColor = getColor(type: cell.rightBorder)
        if cell.rightBorder == .wall  {
            rightWallView.layer.zPosition = 1
        } else if  cell.rightBorder == .boardBorder {
            rightWallView.layer.zPosition = 2
        }
        
        
        leftWallView.backgroundColor = getColor(type: cell.leftBorder)
        if cell.leftBorder == .wall  {
            leftWallView.layer.zPosition = 1
        } else if cell.leftBorder == .boardBorder {
            leftWallView.layer.zPosition = 2
        }

        
        topWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTopWall)))
        bottomWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBottomWall)))
        rightWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapRightWall)))
        leftWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLeftWall)))
        
        tmpLabel.text = "\(cellIndex)"
        
    }
    
    func getColor(type : BorderType) -> UIColor {
        switch type {
        case .wall:
            return colorWall
        case .empty:
            return colorEmptyWall
        case .boardBorder:
            return colorBorder
        }
    }
    
    @IBAction func tapCell(){
        delegate?.tapCell(index: cellIndex)
    }
    
    @objc func tapTopWall(){
        delegate?.tapWall(index: cellIndex, side: .topSide)
    }
    
    @objc func tapBottomWall(){
        delegate?.tapWall(index: cellIndex, side: .bottomSide)
    }
    
    @objc func tapLeftWall(){
        delegate?.tapWall(index: cellIndex, side: .leftSide)
    }
    
    @objc func tapRightWall(){
        delegate?.tapWall(index: cellIndex, side: .rightSide)
    }
    
}
