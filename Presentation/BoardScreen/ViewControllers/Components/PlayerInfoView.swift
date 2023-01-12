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
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var outerRootView: UIView!
    
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
    
    override func layoutSubviews() {
        rootView.layer.cornerRadius = 4
        rootView.clipsToBounds = true
    }
    
    
    func setup(name : String, player : PlayerType){
        playerNameLabel.text = name
        type = player
        setupUI(type: player)
    }
    
    private func setupInfo(state : GameAction){
        if type == .player2 {
            playerInfoLabel.text = state == .searchMatch ? defaultPlayerName : "*Waiting for your move"
        } else {
            switch state {
            case .wallSelected:
                playerInfoLabel.text = "*Tap one cell to move the pawn"
            case .pawnSelected:
                playerInfoLabel.text = "*Tap between cells to insert the wall"
            case .noAction:
                playerInfoLabel.text = "*Select a wall or tap the pawn to move it"
            case .searchMatch:
                playerInfoLabel.text = "*Searching match ..."
            }
        }
    }
    
    private func setupUI(type : PlayerType){
        profileImageView.tintColor = colorPlayerPawn
        profileImageView.tintColor = type == .player1 ? colorPlayerPawn : colorOpponentPawn
        timerImageView.tintColor = type == .player1 ? colorPlayerPawn : colorOpponentPawn
        rootView.backgroundColor = colorCell
        outerRootView.backgroundColor =  type == .player1 ? colorPlayerPawn : colorOpponentPawn
    }
}
