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
    func searchMatch() async -> String {
        do {
            guard let gameId = try await gameInputInterface?.searchOpenMatch() else { return "nomatch" }
            return gameId
        } catch {
            return "nomatch"
        }
    }
    
    func createMatch() async -> Game {
        do {
            let player = Player(name: userInterface?.getUserInfo().name ?? "- -",
                                playerId: userInterface?.getUserInfo().userId ?? "- -",
                                pawnPosition: Pawn.startValue,
                                walls: [])
            guard let gameId = try await gameInputInterface?.createMatch(player: player) else { return Game.defaultValue }
            return gameId
        } catch {
            return Game.defaultValue
        }
    }
    
    func joinMatch(gameId: String) async -> Game {
        do {
            let player = Player(name: userInterface?.getUserInfo().name ?? "- -",
                                playerId: userInterface?.getUserInfo().userId ?? "- -",
                                pawnPosition: Pawn.startValue,
                                walls: [])
            guard let game = try await gameInputInterface?.joinMatch(player: player, gameId: gameId) else { return Game.defaultValue }
            return game
        } catch {
            return Game.defaultValue
        }
    }
    
}
