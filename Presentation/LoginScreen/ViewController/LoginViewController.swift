//
//  LoginViewController.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 07/12/22.
//

import UIKit

class LoginViewController: UIViewController {

    private var viewModel : LoginViewModelProtocol?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playerNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerNameTextField.delegate = self
        playerNameTextField.backgroundColor = mainColor
        playerNameTextField.textColor = textColor
        playerNameTextField.font = regularFont
        playerNameTextField.placeholder = Localized.login_namefield
        
        titleLabel.text = Localized.app_title
        titleLabel.textColor = colorEmptyWall
    }

    init(viewModel: LoginViewModelProtocol?) {
        super.init(nibName: String(describing: "LoginViewController"), bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let name = textField.text else { return false }
        viewModel?.setUserName(name: name)
        return true
    }
}
