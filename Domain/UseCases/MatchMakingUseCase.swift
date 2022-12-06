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
    
    init(gameInputInterface: GameRepositoryInputInterface?,
         userInterface : UserInfoInterface) {
        self.gameInputInterface = gameInputInterface
        self.userInterface = userInterface
    }
}

extension MatchMakingUseCase : MatchMakingUseCaseProtocol {
    func initMatch() async -> GameEvent {
        do {
            let player = Player(name: userInterface?.getUserInfo().name ?? "- -",
                                playerId: userInterface?.getUserInfo().userId ?? "- -",
                                pawnPosition: Pawn.startValue,
                                walls: [])
            try await gameInputInterface?.searchMatch(player: player)
            return .searchingOpponents
        } catch {
            return .error
        }
    }
}
