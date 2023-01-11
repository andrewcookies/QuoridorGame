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
    
    var type : PopupType = .rules {
        didSet {
            setup(type: type)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        root.backgroundColor = .white
        innerRoot.backgroundColor = mainColor

        root.layer.cornerRadius = 4
        root.clipsToBounds = true
        
        innerRoot.layer.cornerRadius = 4
        innerRoot.clipsToBounds = true
    }

    func setup(type : PopupType){
        switch type {
        case .wonMatch:
            titlePopupLabel.text = "*Congratulations"
            contentPopupLabel.text = "*You won the match!"
            rightButtonLabel.isHidden = true
            leftButtonLabel.text = "*Close"
            leftButtonLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(confirmMatchWon)))
            
        case .lostMatch:
            titlePopupLabel.text = "*Oh No"
            contentPopupLabel.text = "*You lost the match!"
            rightButtonLabel.isHidden = true
            leftButtonLabel.text = "*Close"
            leftButtonLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(confirmMatchLost)))
            
        case .quitMatch:
            titlePopupLabel.text = "*Quit the match"
            contentPopupLabel.text = "*You will lost the match. Are you sure?"
            rightButtonLabel.isHidden = false
            leftButtonLabel.text = "*Confirm"
            leftButtonLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(confirmQuitMatch)))
            rightButtonLabel.text = "*Deny"
            rightButtonLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(denyQuitMatch)))
            
        case .rules:
            titlePopupLabel.text = "*Quoridor"
            contentPopupLabel.text = "*Rules...."
            rightButtonLabel.isHidden = true
            leftButtonLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePopup)))

        }
    }
    
    @objc
    func confirmMatchWon(){
        self.dismiss(animated: true)
        delegate?.acceptWonMatch()
    }
    
    @objc
    func confirmMatchLost(){
        self.dismiss(animated: true)
        delegate?.acceptLostMatch()
    }
    
    @objc
    func confirmQuitMatch(){
        self.dismiss(animated: true)
        delegate?.acceptQuitMatch()
    }
    
    @objc
    func denyQuitMatch(){
        self.dismiss(animated: true)
    }
    
    @objc
    func closePopup(){
        self.dismiss(animated: true)
    }
}
