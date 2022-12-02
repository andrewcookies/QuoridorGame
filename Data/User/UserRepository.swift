//
//  UserRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class UserRepository {}

extension UserRepository : UserInfoInterface {
    func getUserInfo() -> User {
        let random = Int.random(in: 0...100)
        return User(userId: "\(random)", name: "User_\(random)")
    }
}
