//
//  UserRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class UserRepository {
    private var currentUser : User?
}

extension UserRepository : UserInfoInterface {
    
    func getUserInfo() -> User {
        return currentUser ?? User(userId: "-", name: "-")
    }
    
    func setUserInfo(user: User) {
        currentUser = user
    }
}
