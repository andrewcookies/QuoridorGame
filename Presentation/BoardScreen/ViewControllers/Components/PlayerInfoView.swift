//
//  PlayerInfoView.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 09/01/23.
//

import UIKit

protocol PlayerInfoViewDelegate : AnyObject {
    func timeUp(player : PlayerType)
}
@IBDesignable
class PlayerInfoView: UIView {
    
    @IBInspectable var playerType : String = "" {
        didSet {
            type = PlayerType(rawValue: playerType) ?? .player1
        }
    }
    
    private var type : PlayerType = .player1
    private var timer: Timer?
    private var timeForPlayer = secondsForPlayer

    
    @IBOutlet var content: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var outerRootView: UIView!
    
    @IBOutlet weak var playerInfoLabel: QLabel!
    @IBOutlet weak var playerNameLabel: QLabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerImageView: UIImageView!
    @IBOutlet weak var timerContainer: UIView!

    
    weak var delegate : PlayerInfoViewDelegate?
    var playerName : String = "" {
        didSet {
            playerNameLabel.text = playerName
            setupUI()
        }
    }

    var actionState : GameAction = .chooseMove {
        didSet {
            setupInfo(state: actionState)
        }
    }
    
    var opponentRemainingWall : Int = 0 {
        didSet {
            timerLabel.text = "\(opponentRemainingWall) walls"
        }
    }
        
    override func layoutSubviews() {
        rootView.layer.cornerRadius = 4
        rootView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        content = view
    }
    
    private func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: "PlayerInfoView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func setupInfo(state : GameAction){
        if type == .player2 {
            switch state {
            case .chooseMove, .pawnSelected, .wallSelected, .loadYourMove:
                playerInfoLabel.text = Localized.board_infobox_opponent_waiting
                
            case .searchMatch:
                playerInfoLabel.text = Localized.defaultNilText
                
            case .waitingForOpponant:
                playerInfoLabel.text = Localized.board_infobox_opponent_turn
                
            }
            
        } else {
            switch state {
            case .wallSelected:
                playerInfoLabel.text = Localized.board_infobox_player_wall
                
            case .pawnSelected:
                playerInfoLabel.text = Localized.board_infobox_player_pawn
                
            case .chooseMove:
                playerInfoLabel.text = Localized.board_infobox_player_turn
                
            case .searchMatch:
                playerInfoLabel.text = Localized.board_infobox_player_searchingMatch
                
            case .waitingForOpponant:
                playerInfoLabel.text = Localized.board_infobox_player_waiting
                
            case .loadYourMove:
                playerInfoLabel.text = Localized.board_infobox_opponent_waiting
                
            }
        }
    }
    
            
    private func setupUI(){
        profileImageView.tintColor = colorPlayerPawn
        profileImageView.tintColor = type == .player1 ? colorPlayerPawn : colorOpponentPawn
        timerImageView.tintColor = type == .player1 ? colorPlayerPawn : colorOpponentPawn
        playerNameLabel.textColor = type == .player1 ? colorPlayerPawn : colorOpponentPawn
        playerInfoLabel.textColor = textColor
        rootView.backgroundColor = colorCell
        outerRootView.backgroundColor =  type == .player1 ? colorPlayerPawn : colorOpponentPawn
        timerImageView.isHidden = type == .player2
    }
    
    func startTimer(){
        timeForPlayer = secondsForPlayer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            timerLabel.text = Localized.defaultNilText
        }
    }
    
    @objc func fireTimer() {
        if timeForPlayer == -1 {
            stopTimer()
            delegate?.timeUp(player: type)
        } else {
            timerLabel.text = timeForPlayer >= 10 ? "00:\(timeForPlayer)" : "00:0\(timeForPlayer)"
            timeForPlayer -= 1
        }
        
    }
    
}
