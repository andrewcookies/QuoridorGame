//
//  EntityMapperInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation

protocol EntityMapperInterface {
    func pawnMapper(from : Any ) -> Pawn
    func wallMapper(from : Any ) -> Wall
    func boardMapper(from : Any ) -> Board
    func gameMapper(from : Any ) -> Game
    func playerMapper(from : Any) -> Player
    func moveMapper(from : Any) -> Move
}
