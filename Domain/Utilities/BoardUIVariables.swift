//
//  BoardUIVariables.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 12/12/22.
//

import Foundation
import UIKit
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

/*
 Default values
 */

let defaultPlayerName = "- -"
let defaultPlayerId = "id_nil"

