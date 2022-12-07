//
//  OnlineGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

enum APIError : Error {
    case currentInfoNIL
    
}

final class MultiplayerOutputGameRepository : EntityMapperInterface {
    
    
    private let db : Firestore?
    private let dbReader : GameRepositoryReadInterface?
    
    
    init( dbReader : GameRepositoryReadInterface?) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        self.dbReader = dbReader
        db = Firestore.firestore()
    }
}


extension MultiplayerOutputGameRepository : GameRepositoryOutputInterface {
    func updateState(state: GameState) async throws {
        guard let gameId = dbReader?.getCurrentGameId() else { throw APIError.currentInfoNIL }
        let collection = db?.collection("games")
        try await collection?.document(gameId).updateData([
            "state" : state.rawValue
        ])
    }
    
    func sendMove(player: Player, moves: [Move], playerType: PlayerType) async throws {
        guard let gameId = dbReader?.getCurrentGameId(), let currentGame = dbReader?.getCurrentGame() else { throw APIError.currentInfoNIL }
        let playerKey = playerType == .player1 ? "player1" : "player2"
        let collection = db?.collection("games")
        let move = moves.last ?? Move.defaultValue
        
        let game = Game(created: currentGame.created,
                        state: currentGame.state,
                        player1: playerType == .player1 ? player : currentGame.player1,
                        player2: playerType == .player2 ? player : currentGame.player2,
                        lastMove: move,
                        gameMoves: moves)
        try await collection?.document(gameId).setData(game.toDictionary())
        /*
        try await collection?.document(gameId).updateData([
            playerKey : player.toDictionary(),
            "lastMove" : move.toDictionary(),
            "gameMoves" : moves
        ])
         */
    }
}

    
                                

