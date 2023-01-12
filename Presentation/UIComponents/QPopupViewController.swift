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
}

protocol PopupDelegate : AnyObject {
    func acceptQuitMatch()
    func acceptLostMatch()
    func acceptWonMatch()
}

class QPopupViewController: UIViewController {

    @IBOutlet weak var root: UIView!
    
    @IBOutlet weak var innerRoot: UIView!
    @IBOutlet weak var titlePopupLabel: QLabel!
    @IBOutlet weak var contentPopupLabel: QLabel!
    
    @IBOutlet weak var leftButtonLabel: QLabel!
    @IBOutlet weak var rightButtonLabel: QLabel!
    
    
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
        
        
        setup()
    }

    func setup(){
        switch type {
        case .wonMatch:
            titlePopupLabel.text = "*Congratulations"
            contentPopupLabel.text = "*You won the match!"
            rightButtonLabel.isHidden = true
            leftButtonLabel.text = "*Close"
            
            
        case .lostMatch:
            titlePopupLabel.text = "*Oh No"
            contentPopupLabel.text = "*You lost the match!"
            rightButtonLabel.isHidden = true
            leftButtonLabel.text = "*Close"
            
        case .quitMatch:
            titlePopupLabel.text = "*Quit the match"
            contentPopupLabel.text = "*You will lost the match. Are you sure?"
            rightButtonLabel.isHidden = false
            leftButtonLabel.text = "*Confirm"
            rightButtonLabel.text = "*Deny"
            
        case .rules:
            titlePopupLabel.text = "*Quoridor"
            contentPopupLabel.text = "*Rules...."
            rightButtonLabel.isHidden = true
            leftButtonLabel.text = "*Got it"

        case .genericError:
            titlePopupLabel.text = "*Ops"
            contentPopupLabel.text = "*Something went wrong. Please retry later"
            rightButtonLabel.isHidden = true
            leftButtonLabel.text = "*Quit"

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
        case .rules:
            break
        case .genericError:
            delegate?.acceptQuitMatch()
        }
        self.dismiss(animated: true)
    }
    
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
}
