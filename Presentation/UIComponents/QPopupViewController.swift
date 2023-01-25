//
//  QPopup.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 11/01/23.
//

import UIKit

enum PopupType {
    case wonMatch
    case lostMatch
    case quitMatch
    case rules
    case genericError
    case opponentQuitMatch
    case ringWallFound
    case noOpponentFound
}

protocol PopupDelegate : AnyObject {
    func acceptQuitMatch()
    func acceptLostMatch()
    func acceptWonMatch()
    func acceptOpponentQuitMatch()
    func acceptError()
    func acceptNoOpponentFound()
}

class QPopupViewController: UIViewController {

    @IBOutlet weak var root: UIView!
    
    @IBOutlet weak var innerRoot: UIView!
    @IBOutlet weak var titlePopupLabel: QLabel!
    @IBOutlet weak var contentPopupLabel: QLabel!
    
    @IBOutlet weak var leftContainerView: UIView!
    @IBOutlet weak var leftButtonLabel: QLabel!
    @IBOutlet weak var rightButtonLabel: QLabel!
    @IBOutlet weak var rightContainerView: UIView!
    
    
    weak var delegate : PopupDelegate?
    
    var type : PopupType = .rules
    
    init() {
        super.init(nibName: String(describing: "QPopup"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        root.backgroundColor = .white
        innerRoot.backgroundColor = mainColor

        root.layer.cornerRadius = 4
        root.clipsToBounds = true
        
        innerRoot.layer.cornerRadius = 4
        innerRoot.clipsToBounds = true
        
        contentPopupLabel.textColor = textColor
        titlePopupLabel.textColor = textColor
        leftButtonLabel.textColor = textColor
        rightButtonLabel.textColor = textColor
        
        setup()
    }

    func setup(){
        switch type {
        case .wonMatch:
            titlePopupLabel.text = Localized.popup_title_matchWon
            contentPopupLabel.text = Localized.popup_content_matchWon
            rightContainerView.isHidden = true
            leftButtonLabel.text = Localized.popup_confirm_confirmWon
            
            
        case .lostMatch:
            titlePopupLabel.text = Localized.popup_title_matchLost
            contentPopupLabel.text = Localized.popup_content_matchLost
            rightContainerView.isHidden = true
            leftButtonLabel.text = Localized.popup_confirm_matchLost
            
        case .quitMatch:
            titlePopupLabel.text = Localized.popup_title_quitMatch
            contentPopupLabel.text = Localized.popup_content_quitMatch
            rightContainerView.isHidden = false
            leftButtonLabel.text = Localized.popup_confirm_quitMatch
            rightButtonLabel.text = Localized.popup_deny_quitMatch
            
        case .rules:
            titlePopupLabel.text = Localized.popup_title_rules
            contentPopupLabel.text = Localized.popup_content_rules
            rightContainerView.isHidden = true
            leftButtonLabel.text = Localized.popup_confirm_rules

        case .genericError:
            titlePopupLabel.text = Localized.popup_title_error
            contentPopupLabel.text = Localized.popup_content_error
            rightContainerView.isHidden = true
            leftButtonLabel.text = Localized.popup_confirm_error

        case .opponentQuitMatch:
            titlePopupLabel.text = Localized.popup_title_opponentQuitMatch
            contentPopupLabel.text = Localized.popup_content_opponentQuitMatch
            rightContainerView.isHidden = true
            leftButtonLabel.text = Localized.popup_confirm_opponentQuitMatch
            
        case .ringWallFound:
            titlePopupLabel.text = Localized.popup_title_invalidWall
            contentPopupLabel.text = Localized.popup_content_invalidWall
            rightContainerView.isHidden = true
            leftButtonLabel.text = Localized.popup_confirm_invalidWall
            
        case .noOpponentFound:
            titlePopupLabel.text = "Oh No"
            contentPopupLabel.text = "Non player found"
            rightContainerView.isHidden = true
            leftButtonLabel.text = "Quit"
        }
    }
 
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        switch type {
        case .wonMatch:
            delegate?.acceptWonMatch()
            
        case .lostMatch:
            delegate?.acceptLostMatch()
            
        case .quitMatch:
            delegate?.acceptQuitMatch()
            
        case .rules, .ringWallFound:
            break
        case .genericError:
            delegate?.acceptError()
            
        case .opponentQuitMatch:
            delegate?.acceptOpponentQuitMatch()
            
        case .noOpponentFound:
            delegate?.acceptNoOpponentFound()
        }
        self.dismiss(animated: true)
    }
    
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
}
