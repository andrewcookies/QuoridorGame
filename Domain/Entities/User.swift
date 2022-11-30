//
//  User.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

struct User {
    let userId : String
    let name : String
    
    enum CodingKeys: String, CodingKey {
        case userId
        case name
    }
}
