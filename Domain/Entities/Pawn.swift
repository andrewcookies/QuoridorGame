//
//  Pawn.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
struct Pawn : Codable {
    var position : Int
    
    enum CodingKeys: String, CodingKey {
        case position
    }
    
    static func == (lhs: Pawn, rhs: Pawn) -> Bool {
        return lhs.position == rhs.position
    }
    
}
