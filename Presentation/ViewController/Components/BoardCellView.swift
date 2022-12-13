//
//  BoardCellView.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 12/12/22.
//

import UIKit
protocol BoardCellDelegate : AnyObject {
    func tapCell(pawnCell : Pawn)
    func tapWall(wall : Wall)
}

enum BoardCellType {
    case playerCell
    case opponentCell
    case allowedCell
    case normalCell
}

class BoardCellView: UIView {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var topWallView: UIView!
    @IBOutlet weak var leftWallView: UIView!
    @IBOutlet weak var bottomWallView: UIView!
    @IBOutlet weak var rightWallView: UIView!
    
    private var drawMode : DrawMode = .normal
    private var cellIndex : Int = -1
    private var cellType : BoardCellType = .normalCell
    private weak var delegate : BoardCellDelegate?
    
    override  func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func getIndex()->Int {
        return cellIndex
    }
    
    func updateColor(allowed : Bool){
        backgroundColor = allowed ? colorAllowedCell : colorCell
    }
    
    func setup(index : Int,
               mode : DrawMode,
               type : BoardCellType,
               delegate : BoardCellDelegate?,
               walls : [Wall]){
        drawMode = mode
        cellType = type
        
        
        cellIndex = index // add reverse logic for index

        
        switch cellType {
        case .playerCell:
            backgroundColor = colorPlayerPawn
            
        case .opponentCell:
            backgroundColor = colorOpponentPawn
            
        case .allowedCell:
            backgroundColor = colorAllowedCell
            
        case .normalCell:
            backgroundColor = colorCell
        }
        
        topWallView.backgroundColor = colorEmptyWall
        bottomWallView.backgroundColor = colorEmptyWall
        rightWallView.backgroundColor = colorEmptyWall
        leftWallView.backgroundColor = colorEmptyWall
        
        for w in walls {
            if cellIndex == w.topLeftCell {
                if w.orientation == .horizontal {
                    bottomWallView.backgroundColor = colorWall
                } else {
                    rightWallView.backgroundColor = colorWall
                }
            } else if cellIndex == w.topRightCell {
                if w.orientation == .horizontal {
                    bottomWallView.backgroundColor = colorWall
                } else {
                    leftWallView.backgroundColor = colorWall
                }
                
            } else if cellIndex == w.bottomRightCell {
                if w.orientation == .horizontal {
                    topWallView.backgroundColor = colorWall
                } else {
                    leftWallView.backgroundColor = colorWall
                }
            } else if cellIndex == w.bottomLeftCell {
                if w.orientation == .horizontal {
                    topWallView.backgroundColor = colorWall
                } else {
                    rightWallView.backgroundColor = colorWall
                }
            }
        }
        
        cellView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCell)))
        topWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTopWall)))
        bottomWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBottomWall)))
        rightWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapRightWall)))
        leftWallView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLeftWall)))
        
    }
    
    @objc func tapCell(){
        let pawn = Pawn(position: cellIndex)
        delegate?.tapCell(pawnCell: pawn)
    }
    
    @objc func tapTopWall(){
        let wall = Wall.initValue
        if drawMode == .normal {
            let wall = Wall(orientation: .horizontal,
                            topLeftCell: cellIndex + bufferTopDownCell,
                            topRightCell: cellIndex + bufferTopRightBottomLeftNormalCell,
                            bottomLeftCell: cellIndex + bufferLeftRightCell,
                            bottomRightCell: cellIndex)
        } else {
            let wall = Wall(orientation: .horizontal,
                            topLeftCell: cellIndex - bufferTopDownCell,
                            topRightCell: cellIndex - bufferTopRightBottomLeftNormalCell ,
                            bottomLeftCell: cellIndex - bufferLeftRightCell,
                            bottomRightCell: cellIndex)
        }
        delegate?.tapWall(wall: wall)
    }
    
    @objc func tapBottomWall(){
        let wall = Wall.initValue
        if drawMode == .normal {
            let wall = Wall(orientation: .horizontal,
                            topLeftCell: cellIndex,
                            topRightCell: cellIndex + bufferLeftRightCell,
                            bottomLeftCell: cellIndex - bufferTopDownCell,
                            bottomRightCell: cellIndex - bufferTopLeftBottomRightReverseCell)
        } else {
            let wall = Wall(orientation: .horizontal,
                            topLeftCell: cellIndex,
                            topRightCell: cellIndex + bufferLeftRightCell ,
                            bottomLeftCell: cellIndex + bufferLeftRightCell,
                            bottomRightCell: cellIndex + bufferTopLeftBottomRightReverseCell)
        }
        delegate?.tapWall(wall: wall)
    }
    
    @objc func tapLeftWall(){
        let wall = Wall.initValue
        if drawMode == .normal {
            let wall = Wall(orientation: .vertical,
                            topLeftCell: cellIndex + bufferTopLeftBottomRightReverseCell,
                            topRightCell: cellIndex + bufferTopDownCell,
                            bottomLeftCell: cellIndex - bufferLeftRightCell,
                            bottomRightCell: cellIndex)
        } else {
            let wall = Wall(orientation: .vertical,
                            topLeftCell: cellIndex - bufferTopLeftBottomRightReverseCell,
                            topRightCell: cellIndex + bufferTopDownCell,
                            bottomLeftCell: cellIndex + bufferLeftRightCell,
                            bottomRightCell: cellIndex)
        }
        delegate?.tapWall(wall: wall)
    }
    
    @objc func tapRightWall(){
        let wall = Wall.initValue
        if drawMode == .normal {
            let wall = Wall(orientation: .vertical,
                            topLeftCell: cellIndex + bufferTopDownCell,
                            topRightCell: cellIndex + bufferTopRightBottomLeftNormalCell,
                            bottomLeftCell: cellIndex,
                            bottomRightCell: cellIndex + bufferLeftRightCell)
        } else {
            let wall = Wall(orientation: .vertical,
                            topLeftCell: cellIndex - bufferTopDownCell,
                            topRightCell: cellIndex - bufferTopRightBottomLeftNormalCell,
                            bottomLeftCell: cellIndex,
                            bottomRightCell: cellIndex - bufferLeftRightCell)
        }
        delegate?.tapWall(wall: wall)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
