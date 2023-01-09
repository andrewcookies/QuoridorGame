//
//  WallView.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 07/01/23.
//

import UIKit

enum WallViewState {
    case normal
    case removed
    case disabled
}

protocol WallViewDelegate : AnyObject {
    func tapWallView(wallIndex : Int)
}


class WallView: UIView {

    
    var wallIndex : Int
    weak var delegate : WallViewDelegate?
    
    var currentState : WallViewState = .normal
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        wallIndex = 0
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(state : WallViewState){
        currentState = state
        switch state {
        case .normal:
            backgroundColor = UIColor.colorWall
        case .removed:
            backgroundColor = colorEmptyWall
        case .disabled:
            backgroundColor = colorWall.withAlphaComponent(0.7)
        }
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapView)))

    }
    
    @objc
    private func tapView(){
        if currentState == .normal {
            delegate?.tapWallView(wallIndex: wallIndex)
        }
    }
}
