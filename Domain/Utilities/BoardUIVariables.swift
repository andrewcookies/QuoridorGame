//
//  BoardUIVariables.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 12/12/22.
//

import Foundation
import UIKit

/*
 Fonts
 */

let titleFont = UIFont(name: "Inter-Bold", size: 48)
let mainFont = UIFont(name: "Inter-SemiBold", size: 18)
let regularFont = UIFont(name: "Inter-Medium", size: 16)

/*
 Colors
 */
let mainColor = UIColor(red: 82/255, green: 80/255, blue: 77/255, alpha: 1.0)
let textColor = UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1.0)

let colorBorder = UIColor.init(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)
let colorCell = UIColor.init(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)
let colorWall = UIColor.init(red: 249/255, green: 226/255, blue: 149/255, alpha: 1.0)
let colorEmptyWall = UIColor.init(red: 90/255, green: 48/255, blue: 52/255, alpha: 1.0)
let colorPlayerPawn = UIColor.init(red: 227/255, green: 150/255, blue: 60/255, alpha: 1.0)
let colorOpponentPawn = UIColor.init(red: 186/255, green: 66/255, blue: 89/255, alpha: 1.0)
let colorAllowedCell = UIColor.init(red: 244/255, green: 208/255, blue: 147/255, alpha: 0.4)

/*
 Const
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

