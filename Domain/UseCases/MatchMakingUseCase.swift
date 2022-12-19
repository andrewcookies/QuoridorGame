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
    func searchMatch() async -> Result<String,MatchMakingError> {
        do {
            guard let gameId = try await gameInputInterface?.searchOpenMatch() else { return .failure(.matchNotFound) }
            return .success(gameId)
        } catch {
            return .failure(.matchNotFound)
        }
    }
    
    func createMatch() async -> Result<Game,MatchMakingError> {
        do {
            let player = Player(name: userInterface?.getUserInfo().name ?? "- -",
                                playerId: userInterface?.getUserInfo().userId ?? "- -",
                                pawnPosition: Pawn.startValue,
                                walls: [])
            guard let game = try await gameInputInterface?.createMatch(player: player) else { return .failure(.APIError) }
            return .success(game)
        } catch {
            return .failure(.APIError)
        }
    }
    
    func joinMatch(gameId: String) async -> Result<Game,MatchMakingError> {
        do {
            let player = Player(name: userInterface?.getUserInfo().name ?? "- -",
                                playerId: userInterface?.getUserInfo().userId ?? "- -",
                                pawnPosition: Pawn.startValue,
                                walls: [])
            guard let game = try await gameInputInterface?.joinMatch(player: player, gameId: gameId) else { return .failure(.APIError) }
            return .success(game)
        } catch {
            return .failure(.APIError)
        }
    }
    
}
