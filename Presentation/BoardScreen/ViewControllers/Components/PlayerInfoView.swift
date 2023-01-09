//
//  PlayerInfoView.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 09/01/23.
//

import UIKit

protocol PlayerInfoViewDelegate : AnyObject {
    
}

class PlayerInfoView: UIView {

    @IBOutlet weak var playerInfoLabel: QLabel!
    @IBOutlet weak var playerNameLabel: QLabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerImageView: UIImageView!
    
    weak var delegate : PlayerInfoViewDelegate?
    
    var actionState : GameAction = .noAction {
        didSet {
            setupInfo(state: actionState)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(name : String, state : GameAction){
        playerNameLabel.text = name
        profileImageView.tintColor = colorPlayerPawn
        setupInfo(state: state)
    }
    
    private func setupInfo(state : GameAction){
        switch state {
        case .wallSelected:
            playerInfoLabel.text = "*Tap one cell to move the pawn"
        case .pawnSelected:
            playerInfoLabel.text = "*Tap between cells to insert the wall"
        case .noAction:
            playerInfoLabel.text = "*Select a wall to put on the board or tap the pawn to move it"
        }
    }
}