//
//  Player.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation

struct Player : Codable, DictionaryConverter {
    let name : String
    let playerId : String
    
    static var defaultValue : Player {
        return Player(name: "- -", playerId: "- -")
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case playerId
    }
    
}
