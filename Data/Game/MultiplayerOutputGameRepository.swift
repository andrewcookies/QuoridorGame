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
    case parseError
    
}

final class MultiplayerOutputGameRepository {
    
    
    private let db : Firestore?
    private let dbReader : MultiplayerLocalRepositoryInterface?
    
    
    init( dbReader : MultiplayerLocalRepositoryInterface?) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        self.dbReader = dbReader
        db = Firestore.firestore()
    }
}


extension MultiplayerOutputGameRepository : GameRepositoryOutputInterface {
    func updateGame(game: Game) async throws {
        do {
            let collection = db?.collection("games")
            guard let gameId = dbReader?.getCurrentGameId() else { throw APIError.currentInfoNIL }
            
            let data = try JSONEncoder().encode(game)
            guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String:Any] else { throw APIError.currentInfoNIL }
            
            try await collection?.document(gameId).setData(dictionary)
            
        } catch {
            throw APIError.currentInfoNIL
        }
    }

}

    
                                

