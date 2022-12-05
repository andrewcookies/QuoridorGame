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
    
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        db = Firestore.firestore()
    }
}


extension MultiplayerOutputGameRepository : GameRepositoryOutputInterface {
    func sendMove(gameId : String, player: Player, moves: [Move], playerType: PlayerType) async throws {
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

    
                                

