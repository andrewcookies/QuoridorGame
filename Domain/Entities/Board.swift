//
//  Board.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

struct Board {
        
    var userPawn : Pawn
    var oppositePawn : Pawn
    var walls : [Wall]
    
    init(){
        userPawn = Pawn(position: 0)
        oppositePawn = Pawn(position: 0)
        walls = []
    }
}
