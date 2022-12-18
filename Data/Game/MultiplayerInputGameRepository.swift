//
//  MultiplayerInputGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

final class MultiplayerInputGameRepository : EntityMapperInterface {
    
    private var gatewayInputInterface : GameGatewayInputInterface?
    private var localRepoWriter : GameRepositoryWriteInterface?
    private var userInterface : UserInfoInterface?
    
    private let db : Firestore?
    
    
    init(gatewayInputInterface: GameGatewayInputInterface,
         localRepoWriter : GameRepositoryWriteInterface?,
         userInterface : UserInfoInterface?) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        db = Firestore.firestore()
        self.gatewayInputInterface = gatewayInputInterface
        self.userInterface = userInterface
        self.localRepoWriter = localRepoWriter
    }

    private func startNewGame(player : Player) async throws -> Game {
        let collection = db?.collection("games")
        let move = Move(playerId: player.playerId, pawnMove: player.pawnPosition, wallMove: player.walls.last ?? Wall.initValue, moveType: .movePawn)
        let timestamp = Double((Date().timeIntervalSince1970 * 1000.0).rounded())
        let game = Game(created: timestamp,
                        state: .waiting,
                        player1: player,
                        player2: Player.startOpponentValue,
                        lastMove: move,
                        gameMoves: [move])
        
        let data = try JSONEncoder().encode(game)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String:Any] else { throw APIError.currentInfoNIL }
        
        let ref = try await collection?.addDocument(data: dictionary)
            //set Listener
        let documentID = ref?.documentID ?? ""
        localRepoWriter?.setCurrentGameId(id: documentID)
        try await setGameListener(id: documentID)
        return game
    }
    
    private func joinMatch(player : Player,
                           game : Game,
                           gameId : String) async throws -> Game {
        let collection = db?.collection("games")
        let move = Move(playerId: player.playerId, pawnMove: player.pawnPosition, wallMove: player.walls.last ?? Wall.initValue, moveType: .movePawn)
        var moves = game.gameMoves
        moves.append(move)
        let newGame = Game(created: game.created,
                           state: .inProgress,
                           player1: game.player1,
                           player2: player,
                           lastMove: move,
                           gameMoves: moves)
        
        let data = try JSONEncoder().encode(newGame)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String:Any] else { throw APIError.currentInfoNIL }
        
        try await collection?.document(gameId).setData(dictionary)
        try await self.setGameListener(id: gameId)
        return newGame
    }
    
    private func setGameListener(id:String) async throws {
        let collection = db?.collection("games")
        collection?.document(id).addSnapshotListener({ [weak self] (documentSnapshot,error) in
            if let document = documentSnapshot,
                let data = document.data(),
                let game = self?.gameMapper(from: data) {
                let lastMove = game.lastMove
                let currentPlayerId = self?.userInterface?.getUserInfo().userId
                
                //avoid game update from my last move
                if lastMove.playerId != currentPlayerId || game.state != .inProgress {
                    GameLog.shared.debug(message: "updated received from \(game.lastMove.playerId), gameState \(game.state)", className: "MultiplayerInputGameRepository")
                    self?.gatewayInputInterface?.updatedReceived(game: game)
                }
                
            }
        })
        
    }
    
}

extension MultiplayerInputGameRepository : GameRepositoryInputInterface {
    func createMatch(player: Player) async throws -> Game {
        GameLog.shared.debug(message: "createMatch", className: "MultiplayerInputGameRepository")
        let game = try await startNewGame(player: player)
        return game
    }
    
    func joinMatch(player: Player, gameId : String) async throws -> Game{
        GameLog.shared.debug(message: "join existing game \(gameId)", className: "MultiplayerInputGameRepository")
        let collection = db?.collection("games")
        
        let querySnapshot = try await collection?.whereField(Game.CodingKeys.state.rawValue, isEqualTo: GameState.waiting.rawValue).getDocuments()
        let waitingGames = querySnapshot?.documents ?? []
        
        if waitingGames.count == 0 {
            GameLog.shared.debug(message: "wrong gameId", className: "MultiplayerInputGameRepository")
            throw APIError.parseError
        } else {
            GameLog.shared.debug(message: "found gameId", className: "MultiplayerInputGameRepository")
            let gameDocument = waitingGames.first
            let gameDictionary = gameDocument?.data() ?? [:]
            let gameId = gameDocument?.documentID ?? ""
            let game = gameMapper(from: gameDictionary)
            localRepoWriter?.setCurrentGameId(id: gameId)
            try await joinMatch(player: player, game: game, gameId: gameId)
            return game
        }
    }
    
    func searchOpenMatch() async throws -> String {
        let collection = db?.collection("games")
        
        let querySnapshot = try await collection?.whereField(Game.CodingKeys.state.rawValue, isEqualTo: GameState.waiting.rawValue).getDocuments()
        let waitingGames = querySnapshot?.documents ?? []
        
        if waitingGames.count == 0 {
            GameLog.shared.debug(message: "start new game", className: "MultiplayerInputGameRepository")
            return "nomatch"
        } else {
            GameLog.shared.debug(message: "join existing game", className: "MultiplayerInputGameRepository")
            let gameDocument = waitingGames.first
            let gameDictionary = gameDocument?.data() ?? [:]
            let gameId = gameDocument?.documentID ?? ""
            let game = gameMapper(from: gameDictionary)
            localRepoWriter?.setCurrentGameId(id: gameId)
            return gameId
        }
    }
    
}
