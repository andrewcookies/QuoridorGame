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
    private var listener : GameListenerInterface?

    private let db : Firestore?
    private var currentGameId : String?
    
    
    init(gatewayInputInterface: GameGatewayInputInterface) {
        FirebaseApp.configure()
        db = Firestore.firestore()
        self.gatewayInputInterface = gatewayInputInterface
    }

    private func startNewGame(player : Player) async throws -> String {
        let collection = db?.collection("games")

        let game = Game(created: Date().timeIntervalSince1970,
                        state: .waiting,
                        player1: player,
                        player2: Player.defaultValue,
                        lastMove: Move.startValue,
                        gameMoves: [])
        
        let ref = try await collection?.addDocument(data: game.toDictionary())
            //set Listener
        let documentID = ref?.documentID ?? ""
        self.currentGameId = documentID
        try await setGameListener(id: documentID)
        return documentID
    }
    
    private func joinMatch(player : Player,
                           game : Game,
                           gameId : String) async throws {
        let collection = db?.collection("games")

        try await collection?.document(gameId).updateData([ "player2" : player.toDictionary(), "state" : GameState.inProgress.rawValue ])
        try await self.setGameListener(id: gameId)
    }
    
    private func setGameListener(id:String) async throws {
        let collection = db?.collection("games")
        collection?.document(id).addSnapshotListener({ [weak self] (documentSnapshot,error) in
            if let document = documentSnapshot, let data = document.data(), let game = self?.gameMapper(from: data) {
                self?.gatewayInputInterface?.updatedReceived(game: game)
            }
        })
        
    }
    
}

extension MultiplayerInputGameRepository : GameInputInterface {
    func searchMatch(player : Player) async throws -> String {
        let collection = db?.collection("games")
        
        let querySnapshot = try await collection?.whereField(Game.CodingKeys.state.rawValue, isEqualTo: GameState.waiting.rawValue).getDocuments()
        let waitingGames = querySnapshot?.documents ?? []
        
        if waitingGames.count == 0 {
            //create new game and wait..
            let id = try await startNewGame(player: player)
            return id
        } else {
            //join waiting match
            let gameDocument = waitingGames.first
            let gameDictionary = gameDocument?.data() ?? [:]
            let gameId = gameDocument?.documentID ?? ""
            let game = gameMapper(from: gameDictionary)
            self.currentGameId = gameId
            try await joinMatch(player: player, game: game, gameId: gameId)
            return gameId
        }
    }
}
