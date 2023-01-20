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
    
    @IBOutlet weak var pawnView: UIView!

    @IBOutlet weak var topLeftCornerView: UIView!
    @IBOutlet weak var topRightCornerView: UIView!
    @IBOutlet weak var bottomRightCornerView: UIView!
    @IBOutlet weak var bottomLeftCornerView: UIView!
    
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
    
    
    override func layoutSubviews() {
        pawnView.layer.cornerRadius = pawnView.frame.size.width / 2
        pawnView.clipsToBounds = true
    }
    
    func updateColor(allowed : Bool){
        if allowed {
            pawnView.isHidden = false
            pawnView.backgroundColor = colorAllowedCell
        } else {
            pawnView.isHidden = true
        }
    }
    
    func setup(cell : BoardCell){
        
        
        cellIndex = cell.index
        contentType = cell.contentType
        
        switch contentType {
        case .playerPawn:
            pawnView.backgroundColor = colorPlayerPawn
            pawnView.isHidden = false
            
        case .opponentPawn:
            pawnView.backgroundColor = colorOpponentPawn
            pawnView.isHidden = false
            
        case .allowed:
            pawnView.backgroundColor = colorAllowedCell
            pawnView.isHidden = false
            
        case .empty:
            pawnView.isHidden = true
        }
        
        cellView.backgroundColor = colorCell

        
        //top side
        if cell.topRightBorder != .empty {
            topWallView.backgroundColor = getColor(type: cell.topRightBorder)
            topRightCornerView.backgroundColor = getColor(type: cell.topRightBorder)
        }
        
        if cell.topLeftBorder != .empty {
            topLeftCornerView.backgroundColor = getColor(type: cell.topLeftBorder)
            topWallView.backgroundColor = getColor(type: cell.topLeftBorder)
        }
        
        if cell.topRightBorder == .empty && cell.topLeftBorder == .empty {
            topLeftCornerView.backgroundColor = getColor(type: .empty)
            topWallView.backgroundColor = getColor(type: .empty)
            topRightCornerView.backgroundColor = getColor(type: .empty)
        }
        
        
        //bottom side
        if cell.bottomRightBorder != .empty {
            bottomRightCornerView.backgroundColor = getColor(type: cell.bottomRightBorder)
            bottomWallView.backgroundColor = getColor(type: cell.bottomRightBorder)
        }
        
        if cell.bottomLeftBorder != .empty {
            bottomLeftCornerView.backgroundColor = getColor(type: cell.bottomLeftBorder)
            bottomWallView.backgroundColor = getColor(type: cell.bottomLeftBorder)
        }
        
        if cell.bottomRightBorder == .empty && cell.bottomLeftBorder == .empty {
            bottomRightCornerView.backgroundColor = getColor(type: .empty)
            bottomLeftCornerView.backgroundColor = getColor(type: .empty)
            bottomWallView.backgroundColor = getColor(type: .empty)
        }
        
        //right side
        if cell.rightTopBorder != .empty {
            rightWallView.backgroundColor =  getColor(type: cell.rightTopBorder)
            topRightCornerView.backgroundColor = getColor(type: cell.rightTopBorder)
        }
        
        if cell.rightBottomBorder != .empty {
            rightWallView.backgroundColor =  getColor(type: cell.rightBottomBorder)
            bottomRightCornerView.backgroundColor = getColor(type: cell.rightBottomBorder)
        }
        
        if cell.rightTopBorder == .empty && cell.rightBottomBorder == .empty {
            rightWallView.backgroundColor =  getColor(type: .empty)
        }
        
        //left side
        if cell.leftTopBorder != .empty {
            leftWallView.backgroundColor =  getColor(type: cell.leftTopBorder)
            topLeftCornerView.backgroundColor = getColor(type: cell.leftTopBorder)
        }
        
        if cell.leftBottomBorder != .empty {
            leftWallView.backgroundColor =  getColor(type: cell.leftBottomBorder)
            bottomLeftCornerView.backgroundColor = getColor(type: cell.leftBottomBorder)
        }
        
        if cell.leftTopBorder == .empty &&  cell.leftBottomBorder == .empty {
            leftWallView.backgroundColor =  getColor(type: .empty)
        }
        
        topWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTopWall)))
        bottomWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBottomWall)))
        rightWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapRightWall)))
        leftWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLeftWall)))
        
        tmpLabel.text = "\(cellIndex)"
        tmpLabel.isHidden = matchType != .demo
        
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
