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
    case null
}

struct Wall : Codable {
    let orientation : WallOrientation
    let topLeftCell : Int
    let topRightCell : Int
    let bottomLeftCell : Int
    let bottomRightCell : Int

    enum CodingKeys: String, CodingKey {
        case orientation
        case topLeftCell
        case topRightCell
        case bottomLeftCell
        case bottomRightCell
    }
    
    static var initValue : Wall {
        return Wall(orientation: .null, topLeftCell: -1, topRightCell: -1, bottomLeftCell: -1, bottomRightCell: -1)
    }
    
}
