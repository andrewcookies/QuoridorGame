//
//  MatchMakingUseCase.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation

final class MatchMakingUseCase {
    
    private var gameInputInterface : GameRepositoryInputInterface?
    private var userInterface : UserInfoInterface?
    private var dbWriter : GameRepositoryWriteInterface?
    
    init(gameInputInterface: GameRepositoryInputInterface?,
         userInterface : UserInfoInterface?,
         dbWriter : GameRepositoryWriteInterface?) {
        self.gameInputInterface = gameInputInterface
        self.userInterface = userInterface
        self.dbWriter = dbWriter
    }
}

extension MatchMakingUseCase : MatchMakingUseCaseProtocol {
    func initMatch() async -> GameEvent {
        do {
            let player = Player(name: userInterface?.getUserInfo().name ?? "- -",
                                playerId: userInterface?.getUserInfo().userId ?? "- -",
                                pawnPosition: Pawn.startValue,
                                walls: [])
            guard let gameId = try await gameInputInterface?.searchMatch(player: player) else { return .error }
            dbWriter?.setCurrentGameId(id: gameId)
            return .searchingOpponents
        } catch {
            return .error
        }
    }
}
