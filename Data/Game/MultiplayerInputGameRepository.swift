//
//  MultiplayerInputGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

final class MultiplayerInputGameRepository {
    
    private var gameInputUseCase : GameInputUseCaseProtocol?
    private var localRepoWriter : MultiplayerLocalRepositoryInterface?
    
    private let db : Firestore?
    
    
    init(gameInputUseCase: GameInputUseCaseProtocol,
         localRepoWriter : MultiplayerLocalRepositoryInterface?) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        db = Firestore.firestore()
        self.gameInputUseCase = gameInputUseCase
        self.localRepoWriter = localRepoWriter
    }

    private func startNewGame(game : Game) async throws -> Game {
        let collection = db?.collection("games")
        let data = try JSONEncoder().encode(game)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String:Any] else { throw APIError.currentInfoNIL }
        
        let ref = collection?.addDocument(data: dictionary)
            //set Listener
        let documentID = ref?.documentID ?? ""
        localRepoWriter?.setCurrentGameId(gameId: documentID)
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
                let game = self?.gameMapper(dictionary: data) {
                let lastMove = game.lastMove
                
                //avoid game update from my last move
                GameLog.shared.debug(message: "updated received from \(lastMove.playerId), gameState \(game.state)", className: "MultiplayerInputGameRepository")
                self?.gameInputUseCase?.updateGameFromOpponent(game: game)
            }
        })
        
    }
    
    private func gameMapper(dictionary: [String:Any]) -> Game? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Game.self, from: data)
        } catch {
            return nil
        }
    }
    
}

extension MultiplayerInputGameRepository : GameRepositoryInputInterface {
    func createMatch(game: Game) async throws -> Game {
        GameLog.shared.debug(message: "createMatch", className: "MultiplayerInputGameRepository")
        let game = try await startNewGame(game: game)
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
            guard let gameDictionary = gameDocument?.data(), let gameId = gameDocument?.documentID, let game = gameMapper(dictionary: gameDictionary) else { throw APIError.currentInfoNIL }
            
            localRepoWriter?.setCurrentGameId(gameId: gameId)
            let res = try await joinMatch(player: player, game: game, gameId: gameId)
            return res
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
            let gameId = gameDocument?.documentID ?? ""
            localRepoWriter?.setCurrentGameId(gameId: gameId)
            return gameId
        }
    }
    
}
