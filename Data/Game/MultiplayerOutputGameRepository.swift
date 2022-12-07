//
//  OnlineGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

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
        guard let gameId = dbReader?.getCurrentGameId() else {
            return
        }
        let collection = db?.collection("games")
        if state == .quit {
            try await collection?.document(gameId).delete()
        } else {
            try await collection?.document(gameId).updateData([
                "state" : state.rawValue
            ])
        }
    }
    
    func sendMove(player: Player, moves: [Move], playerType: PlayerType) async throws {
        guard let gameId = dbReader?.getCurrentGameId() else {
            return 
        }
        let playerKey = playerType == .player1 ? "player1" : "player2"
        let collection = db?.collection("games")
        let move = moves.last
        try await collection?.document(gameId).updateData([
            playerKey : player.toDictionary(),
            "lastMove" : move?.toDictionary(),
            "gameMoves" : moves
        ])
    }
}

    
                                

