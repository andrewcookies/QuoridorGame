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
let colorBorder = UIColor.systemYellow
let colorCell = UIColor.systemOrange
let colorWall = UIColor.systemBrown
let colorEmptyWall = UIColor.darkGray
let colorPlayerPawn = UIColor.systemRed
let colorOpponentPawn = UIColor.systemCyan
let colorAllowedCell = UIColor.systemGray

/*
 Const
 */

let numberOfCellPerRow = 9
let numberWallPerPlayer = 10
let startPlayer1PawnPosition = 4
let startPlayer2PawnPosition = 84
let bufferLeftRightCell = 1
let bufferTopDownCell = 10
let bufferTopRightBottomLeftNormalCell = 11
let bufferTopLeftBottomRightReverseCell = 9
let leftRightBorder = [-1,9,19,29,39,49,59,69,79]
let bottomCellsBorder = [0,1,2,3,4,5,6,7,8,9]
let topCellsBorder = [80,81,82,83,84,85,86,87,88,89]
let leftCellsBorder = [0,10,20,30,40,50,60,70,80]
let rightCellsBorder = [8,18,28,38,48,58,68,78,88]