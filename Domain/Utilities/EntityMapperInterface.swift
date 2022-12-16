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
            do {
                let data = try JSONSerialization.data(withJSONObject: d, options: [])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(Pawn.self, from: data)
            } catch {
                return Pawn.defaultValue
            }
        }
        return Pawn.defaultValue
    }
    
    func wallMapper(from: Any) -> Wall {
        
        if let d = from as? [String:Any] {
            do {
                let data = try JSONSerialization.data(withJSONObject: d, options: [])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(Wall.self, from: data)
            } catch {
                return Wall.initValue
            }
        }
        return Wall.initValue
    }
    
    
    func gameMapper(from: Any) -> Game {
        if let d = from as? [String:Any] {
            do {
                let data = try JSONSerialization.data(withJSONObject: d, options: [])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(Game.self, from: data)
            } catch {
                return Game.defaultValue
            }
        }
        return Game.defaultValue
    }
    
    func playerMapper(from: Any) -> Player {
        if let d = from as? [String:Any] {
            do {
                let data = try JSONSerialization.data(withJSONObject: d, options: [])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(Player.self, from: data)
            } catch {
                return Player.startPlayerValue
            }
        }
        return Player.startPlayerValue
    }
    
    func moveMapper(from: Any) -> Move {
        if let d = from as? [String:Any] {
            do {
                let data = try JSONSerialization.data(withJSONObject: d, options: [])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(Move.self, from: data)
            } catch {
                return Move.defaultValue
            }
        }
        return Move.defaultValue
    }
}
