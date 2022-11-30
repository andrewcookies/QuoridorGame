//
//  Pawn.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
struct Pawn : Codable {
    let position : Int
    
    enum CodingKeys: String, CodingKey {
        case position
    }
    
}
