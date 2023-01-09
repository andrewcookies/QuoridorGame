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
    
    private var type : PlayerType = .player1

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
    
    static func getView() -> UIView? {
        guard let _view = Bundle.main.loadNibNamed("PlayerInfoView", owner: self, options: nil)?.first,
              let view = _view as? PlayerInfoView
        else { return nil }
        return view
    }
    
    func setup(name : String, player : PlayerType){
        playerNameLabel.text = name
        profileImageView.tintColor = colorPlayerPawn
        profileImageView.tintColor = player == .player1 ? colorPlayerPawn : colorOpponentPawn
        
        type = player
    }
    
    private func setupInfo(state : GameAction){
        if type == .player2 {
            playerInfoLabel.text = "*Waiting for your move"
        } else {
            switch state {
            case .wallSelected:
                playerInfoLabel.text = "*Tap one cell to move the pawn"
            case .pawnSelected:
                playerInfoLabel.text = "*Tap between cells to insert the wall"
            case .noAction:
                playerInfoLabel.text = "*Select a wall or tap the pawn to move it"
            }
        }
    }
}
