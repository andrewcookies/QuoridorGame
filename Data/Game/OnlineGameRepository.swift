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
    
    @Published private var currentGame : Game = Game.defaultValue
    
    
    private let db : Firestore?
    private var currentGameId : String?
    private var playerName : String {
        userInterface?.getUserInfo().name ?? "- -"
    }
    private var playerId : String {
        userInterface?.getUserInfo().userId ?? "- -"
    }
   
    
    private var userInterface : UserInfoInterface?
    private var readerInterface : GameRepositoryReadInterface?
    
    
    init(userInterface : UserInfoInterface?,
         readerInterface : GameRepositoryReadInterface) {
        FirebaseApp.configure()
        db = Firestore.firestore()
    }
    
    private func startNewGame(){
        let collection = db?.collection("games")
        let newPlayer = Player(name: playerName,
                               playerId: playerId,
                               pawnPosition: Pawn.startValue,
                               walls: [])
        let game = Game(created: Date().timeIntervalSince1970,
                        state: .waiting,
                        player1: newPlayer,
                        player2: Player.defaultValue,
                        lastMove: Move.startValue,
                        gameMoves: [])
        
        if let ref = collection?.addDocument(data: game.toDictionary()){
            //set Listener
            self.currentGameId = ref.documentID
            setGameListener(id: ref.documentID)
        }
    }
    
    private func joinMatch(game : Game, gameId : String) {
        let collection = db?.collection("games")
        let newPlayer =  Player(name: playerName,
                                playerId: playerId,
                                pawnPosition: Pawn.startValue,
                                walls: [])

        collection?.document(gameId).updateData([
            "player2" : newPlayer.toDictionary(),
            "state" : GameState.inProgress.rawValue
        ])
        
        setGameListener(id: gameId)
    }
    
    private func setGameListener(id:String){
        let collection = db?.collection("games")
        collection?.document(id).addSnapshotListener({ [weak self] documentSnapshot, error in
            if let document = documentSnapshot, let data = document.data(), let game = self?.gameMapper(from: data) {
                self?.currentGame = game
            }
        })
    }
    
}


extension OnlineGameRepository : GameInterface {
    var gameListener: Published<Game>.Publisher {
        $currentGame
    }
    
    func updatePawn(pawn: Pawn) async throws {
        let collection = db?.collection("games")
        if let id = currentGameId {
            let move = Move(playerName: playerName, pawnMove: pawn, wallMove: Wall.nullValue)
            var game = readerInterface?.getCurrentGame() ?? Game.defaultValue
            var playerKey = "-"
            var currentPlayer = game.player1
            
            if game.player1.playerId == userInterface?.getUserInfo().userId ?? "- -" {
                playerKey = "player1"
            } else {
                playerKey = "player2"
                currentPlayer = currentGame.player2
            }
            
            var player = Player(name: currentPlayer.name, playerId: currentPlayer.playerId, pawnPosition: pawn, walls: currentPlayer.walls)
            var gameMoves = game.gameMoves
            gameMoves.append(move)
            

            
            try await collection?.document(id).updateData([
                playerKey : player.toDictionary(),
                "lastMove" : move.toDictionary(),
                "gameMoves" : gameMoves
            ])
        }
    }
    
    func updateWalls(wall: Wall) async throws {
        let collection = db?.collection("games")
        if let id = currentGameId {
            let move = Move(playerName: playerName, pawnMove: Pawn.defaultValue, wallMove: wall)
            var game = readerInterface?.getCurrentGame() ?? Game.defaultValue
            var playerKey = "-"
            
            var currentPlayer = game.player1
            if game.player1.playerId == userInterface?.getUserInfo().userId ?? "- -" {
                playerKey = "player1"
            } else {
                playerKey = "player2"
                currentPlayer = currentGame.player2
            }
           
            var walls = currentPlayer.walls
            walls.append(wall)
            var player = Player(name: currentPlayer.name, playerId: currentPlayer.playerId, pawnPosition: currentPlayer.pawnPosition, walls: walls)
           
            var gameMoves = game.gameMoves
            gameMoves.append(move)

            
            try await collection?.document(id).updateData([
                playerKey : player.toDictionary(),
                "lastMove" : move.toDictionary(),
                "gameMoves" : gameMoves
            ])
        }
    }
    
    
    func searchMatch() async throws {
        let collection = db?.collection("games")
        
        let querySnapshot = try await collection?.whereField(Game.CodingKeys.state.rawValue, isEqualTo: GameState.waiting.rawValue).getDocuments()
        let waitingGames = querySnapshot?.documents ?? []
        
        if waitingGames.count == 0 {
            //create new game and wait..
            self.startNewGame()
        } else {
            //join waiting match
            let gameDocument = waitingGames.first
            let gameDictionary = gameDocument?.data() ?? [:]
            let gameId = gameDocument?.documentID ?? ""
            let game = gameMapper(from: gameDictionary)
            self.currentGameId = gameId
            self.joinMatch(game: game, gameId: gameId)
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
        return Player.defaultValue
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
    
                                

