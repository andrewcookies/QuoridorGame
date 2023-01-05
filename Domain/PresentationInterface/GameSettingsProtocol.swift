//
//  GameSettingProtocol.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 05/01/23.
//

import Foundation

protocol GameSettingsProtocol {
    var defaultGame : Game { get }
    var startPlayerPosition : Pawn { get }
    var startOpponentPosition : Pawn { get }
    var startWall : Wall { get }
    
    func getWinningCells(mode : PlayerType) -> [Pawn]
    func nextTopPosition(position: Int, mode : PlayerType, walls : [Wall]) -> Int?
    func nextBottomPosition(position: Int, mode : PlayerType, walls : [Wall]) -> Int?
    func nextRightPosition(position: Int, mode : PlayerType, walls : [Wall]) -> Int?
    func nextLeftPosition(position: Int, mode : PlayerType, walls : [Wall]) -> Int?

    func outOfBoard(pawn : Pawn) -> Bool
    func outOfBoard(wall : Wall) -> Bool
}
