//
//  OnlineGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

final class OnlineGameRepository {
    
    @Published private var localBoard : Board = Board.defaultValue
    private let db : Firestore?
    
    init() {
        FirebaseApp.configure()
        db = Firestore.firestore()
    }
    
}


extension OnlineGameRepository : GameInterface {
    var boardListener: Published<Board>.Publisher {
        $localBoard
    }
    
    func updatePawn(pawn: Pawn) async throws {
        //TODO:
    }
    
    func updateWalls(wall: Wall) async throws {
        //TODO
    }
    
    
    func searchMatch() async throws {
        let collection = db?.collection("games")
        collection?
            .whereField(Game.CodingKeys.state.rawValue, isEqualTo: GameState.waiting.rawValue)
            .getDocuments() { [weak self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let documents = querySnapshot?.documents
                    if documents?.count == 0 {
                        //no waiting game, create a game
                        let newPlayer = Player(name: "newPlayer", playerId: "2")
                        let game = Game(created: Date().timeIntervalSince1970,
                                        state: .waiting,
                                        player1: Player(name: "newPlayer", playerId: "2"),
                                        player2: Player.defaultValue,
                                        board: Board.startValue,
                                        lastMove: Move(player: newPlayer, pawnMove: Pawn.startValue, wallMove: Wall.defaultValue),
                                        gameMoves: [])
                        
                        collection?.addDocument(data: game.toDictionary())
                        
                        //set Listener
                        
                    } else {
                        //add player to exsisting game
                        if let document = documents?.first,
                            let game = self?.gameMapper(from: document.data()) {
                            let id = document.documentID
                            let newPlayer = Player(name: "newPlayer", playerId: "2")
                            
                            let newGame = Game(created: game.created,
                                               state: game.state,
                                               player1: game.player1,
                                               player2: newPlayer,
                                               board: game.board,
                                               lastMove: game.lastMove,
                                               gameMoves: game.gameMoves)
                            
                            collection?.document(id).setData(newGame.toDictionary())
                            
                        }
                    }
                    
                }
            }
    }
    
}


extension OnlineGameRepository : EntityMapperInterface {
    func pawnMapper(from: Any) -> Pawn {
        if let d = from as? [String:Any] {
            let position = d["position"] as? Int ?? 0
            return Pawn(position : position)
        }
        return Pawn.defaultValue
    }
    
    func wallMapper(from: Any) -> Wall {
        
        if let d = from as? [String:Any] {
            let position = WallPosition(rawValue: d["position"] as? String ?? "") ?? .top
            let orientation = WallOrientation(rawValue: d["orientation"] as? String ?? "") ?? .vertical
            let topLeftCell = d["topLeftCell"] as? Int ?? 0
            return Wall(orientation: orientation, position: position, topLeftCell: topLeftCell)
        }
        return Wall.defaultValue
    }
    
    func boardMapper(from: Any) -> Board {
        if let d = from as? [String:Any] {
            let player1Pawn = pawnMapper(from: d["player1Pawn"] as? [String:Any] ?? [:])
            let player2Pawn = pawnMapper(from: d["player2Pawn"] as? [String:Any] ?? [:])
            let player1RemaingWalls = d["player1RemaingWalls"] as? Int ?? 0
            let player2RemaingWalls = d["player2RemaingWalls"] as? Int ?? 0
            let wallsOnBoard = d["wallsOnBoard"] as? [Wall] ?? []
            return Board(player1Pawn: player1Pawn,
                         player1RemaingWalls: player1RemaingWalls,
                         player2Pawn: player2Pawn,
                         player2RemaingWalls: player2RemaingWalls,
                         wallsOnBoard: wallsOnBoard)
        }
        return Board.defaultValue
    }
    
    func gameMapper(from: Any) -> Game {
        if let d = from as? [String:Any] {
            let created = d["created"] as? Double ?? 0.0
            let state = GameState(rawValue: d["state"] as? String ?? "") ?? .terminated
            let player1 = playerMapper(from: d["player1"] as? [String:Any] ?? [:])
            let player2 = playerMapper(from: d["player2"] as? [String:Any] ?? [:])
            let board = boardMapper(from: d["board"] as? [String:Any] ?? [:])
            let lastMove = moveMapper(from: d["lastMove"] as? [String:Any] ?? [:])
            
            var tmpMoves = [Move]()
            let array = d["gameMoves"] as? [[String:Any]] ?? []
            for m in array {
                tmpMoves.append(moveMapper(from: m))
            }
            
            return Game(created: created, state: state, player1: player1, player2: player2, board: board, lastMove: lastMove, gameMoves: tmpMoves)
        }
        return Game.defaultValue
    }
    
    func playerMapper(from: Any) -> Player {
        if let d = from as? [String:Any] {
            let name = d["name"] as? String ?? ""
            let playerId = d["playerId"] as? String ?? ""
            return Player(name: name, playerId: playerId)
        }
        return Player.defaultValue
    }
    
    func moveMapper(from: Any) -> Move {
        if let d = from as? [String:Any] {
            let player = playerMapper(from: d["player"] as? [String:Any] ?? [:])
            let pawnMove = pawnMapper(from: d["pawnMove"] as? [String:Any] ?? [:])
            let wallMove = wallMapper(from: d["wallMove"] as? [String:Any] ?? [:])
        }
        return Move.defaultValue
    }
}
    
                                

