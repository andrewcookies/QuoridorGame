//
//  PlayerInfoView.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 09/01/23.
//

import UIKit
enum TimerType {
    case matchmaking
    case yourTurn
}
protocol PlayerInfoViewDelegate : AnyObject {
    func timeRanOut(player : PlayerType)
    func timeRanOutMatchmaking()
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
    private var timerType : TimerType = .yourTurn

    
    @IBOutlet var content: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var outerRootView: UIView!
    
    @IBOutlet weak var playerInfoLabel: QLabel!
    @IBOutlet weak var playerNameLabel: QLabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var timerLabel: UILabel!
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
    
    var opponentRemainingWall : Int = numberWallPerPlayer
    
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
                playerInfoLabel.text = Localized.board_infobox_opponent_turn + " - \(opponentRemainingWall) walls"
                
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
        outerRootView.backgroundColor =  type == .player1 ? colorPlayerPawn : colorOpponentPawn
        rootView.backgroundColor = colorCell
        
        profileImageView.tintColor = colorPlayerPawn
        profileImageView.tintColor = type == .player1 ? colorPlayerPawn : colorOpponentPawn
        playerNameLabel.textColor = type == .player1 ? colorPlayerPawn : colorOpponentPawn
        playerInfoLabel.textColor = textColor
        
        timerContainer.isHidden = type == .player2
    }
    
    func startTimer(matchmaking : Bool? = false){
        
        if timer != nil  {
            stopTimer()
        }
        
        timeForPlayer = matchmaking ?? false ? matchmakingSeconds : secondsForPlayer
        timerType = matchmaking ?? false ? .matchmaking : .yourTurn
        
        timer =  Timer.scheduledTimer(
             timeInterval: TimeInterval(1.0),
             target      : self,
             selector    : #selector(fireTimer),
             userInfo    : nil,
             repeats     : true)
        
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerLabel.text = defaultPlayerName
    }
    
    @objc func fireTimer() {
        if timeForPlayer == -1 {
            stopTimer()
            if timerType == .yourTurn {
                delegate?.timeRanOut(player: type)
            } else {
                delegate?.timeRanOutMatchmaking()
            }
        } else {
            timerLabel.text = timeForPlayer >= 10 ? "00:\(timeForPlayer)" : "00:0\(timeForPlayer)"
            timeForPlayer -= 1
        }
        
    }
    
}
