//
//  BoardUIVariables.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 12/12/22.
//

import Foundation
import UIKit


extension UIColor {
    static var colorWall : UIColor { return UIColor.init(red: CGFloat(249/255), green: CGFloat(226/255), blue: CGFloat(149.0/255), alpha: CGFloat(1.0)) }
}
/*
 Colors
 */
let colorBorder = UIColor.black
let colorCell = UIColor.brown
let colorWall = UIColor.yellow
let colorEmptyWall = UIColor.red
let colorPlayerPawn = UIColor.green
let colorOpponentPawn = UIColor.blue
let colorAllowedCell = UIColor.systemGray

/*
 Const
 
 
 let colorBorder = UIColor.init(red: 90, green: 48, blue: 52, alpha: 1.0) //90 48 52
 let colorCell = UIColor.init(red: 44, green: 44, blue: 44, alpha: 1.0) //44 44 44
 let colorWall = UIColor.init(red: 249, green: 226, blue: 149, alpha: 1.0) //249 226 149
 let colorWallDeselected = UIColor.init(red: 249, green: 226, blue: 149, alpha: 0.8) //249 226 149
 let colorEmptyWall = UIColor.init(red: 90, green: 48, blue: 52, alpha: 1.0) //90 48 52
 let colorPlayerPawn = UIColor.init(red: 245, green: 217, blue: 154, alpha: 1.0) //245 217 154
 let colorOpponentPawn = UIColor.init(red: 85, green: 44, blue: 40, alpha: 1.0) // 85 44 40
 let colorAllowedCell = UIColor.init(red: 245, green: 217, blue: 154, alpha: 0.8)
 */

let numberOfCellPerRow = 9
let numberWallPerPlayer = 10
let startPlayer1PawnPosition = 84
let startPlayer2PawnPosition = 4
let pawnNilMove = -1
let bufferLeftRightCell = 1
let bufferTopDownCell = 10
let leftRightBorder = [-1,9,19,29,39,49,59,69,79]
let topCellsBorder = [0,1,2,3,4,5,6,7,8]
let bottomCellsBorder = [80,81,82,83,84,85,86,87,88]
let leftCellsBorder = [0,10,20,30,40,50,60,70,80]
let rightCellsBorder = [8,18,28,38,48,58,68,78,88]
let wallViiewConst = 80

/*
 Default values
 */

let defaultPlayerName = "- -"
let defaultPlayerId = "id_nil"

