//
//  LoginViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 07/12/22.
//

import Foundation


protocol LoginViewModelProtocol {
    func setUserName(name : String)
}

struct LoginViewNavigation {
    let startGame: ()->()
}


final class LoginViewModel {
    
    private var userInterface : UserInfoInterface?
    private var navigation : LoginViewNavigation?
    
    init(userInterface: UserInfoInterface?,
         navigation: LoginViewNavigation?) {
        self.userInterface = userInterface
        self.navigation = navigation
    }
    
}

extension LoginViewModel : LoginViewModelProtocol {
    func setUserName(name: String) {
        let random = Int.random(in: 0...100)
        let timestamp = Int(Date().timeIntervalSince1970)
        userInterface?.setUserInfo(user: User(userId: "id_\(random)-\(timestamp)", name: name))
        navigation?.startGame()
    }
}
