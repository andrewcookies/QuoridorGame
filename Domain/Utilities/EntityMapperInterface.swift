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
    func gameMapper(from : Any ) -> Game
    func playerMapper(from : Any) -> Player
    func moveMapper(from : Any) -> Move
}

extension EntityMapperInterface {
    func pawnMapper(from: Any) -> Pawn {
        if let d = from as? [String:Any] {
            let position = d["position"] as? Int ?? 0
            return Pawn(position : position)
        }
        return Pawn.defaultValue
    }
    
    func wallMapper(from: Any) -> Wall {
        
        if let d = from as? [String:Any] {
            let orientation = WallOrientation(rawValue: d["orientation"] as? String ?? "") ?? .vertical
            let topLeftCell = d["topLeftCell"] as? Int ?? 0
            let topRightCell = d["topRightCell"] as? Int ?? 0
            let bottomLeftCell = d["bottomLeftCell"] as? Int ?? 0
            let bottomRightCell = d["bottomRightCell"] as? Int ?? 0

            return Wall(orientation: orientation, topLeftCell: topLeftCell, topRightCell: topRightCell, bottomLeftCell: bottomLeftCell, bottomRightCell: bottomRightCell)
        }
        return Wall.initValue
    }
    
    
    func gameMapper(from: Any) -> Game {
        if let d = from as? [String:Any] {
            let created = d["created"] as? Double ?? 0.0
            let state = GameState(rawValue: d["state"] as? String ?? "") ?? .quit
            let player1 = playerMapper(from: d["player1"] as? [String:Any] ?? [:])
            let player2 = playerMapper(from: d["player2"] as? [String:Any] ?? [:])
            let lastMove = moveMapper(from: d["lastMove"] as? [String:Any] ?? [:])
            
            var tmpMoves = [Move]()
            let array = d["gameMoves"] as? [[String:Any]] ?? []
            for m in array {
                tmpMoves.append(moveMapper(from: m))
            }
            
            return Game(created: created,
                        state: state,
                        player1: player1,
                        player2: player2,
                        lastMove: lastMove,
                        gameMoves: tmpMoves)
        }
        return Game.defaultValue
    }
    
    func playerMapper(from: Any) -> Player {
        if let d = from as? [String:Any] {
            let name = d["name"] as? String ?? ""
            let playerId = d["playerId"] as? String ?? ""
            let pawnPosition = pawnMapper(from: d["pawnPosition"] as? [String:Any] ?? [:])
            
            var tmpWalls = [Wall]()
            let wallsOnBoard = d["walls"] as? [[String:Any]] ?? []
            for w in wallsOnBoard {
                tmpWalls.append(wallMapper(from: w))
            }
            
            return Player(name: name, playerId: playerId,pawnPosition: pawnPosition,walls: tmpWalls)
        }
        return Player.startPlayerValue
    }
    
    func moveMapper(from: Any) -> Move {
        if let d = from as? [String:Any] {
            let playerName = d["playerName"] as? String ?? ""
            let pawnMove = pawnMapper(from: d["pawnMove"] as? [String:Any] ?? [:])
            let wallMove = wallMapper(from: d["wallMove"] as? [String:Any] ?? [:])
            return Move(playerName: playerName, pawnMove: pawnMove, wallMove: wallMove)
        }
        return Move.defaultValue
    }
}
