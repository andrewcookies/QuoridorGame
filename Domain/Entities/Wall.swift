//
//  Wall.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation
enum WallOrientation: String, Codable {
    case vertical
    case horizontal
}

enum WallPosition: String, Codable {
    case top
    case bottom
    case middle
    case right
    case left
}

struct Wall : Codable, DictionaryConverter {
    let orientation : WallOrientation
    let position : WallPosition
    let topLeftCell : Int
    
    enum CodingKeys: String, CodingKey {
        case orientation
        case position
        case topLeftCell
    }
    
    static var defaultValue : Wall {
        return Wall(orientation: .horizontal, position: .bottom, topLeftCell: 10)
    }
}
