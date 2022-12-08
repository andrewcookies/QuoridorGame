//
//  GameGateway.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation

final class GameGatewayOutput {
    
    private var gameInterface : GameRepositoryOutputInterface?
    private var dataBaseReaderInterface : GameRepositoryReadInterface?
    private var userInterface : UserInfoInterface?

    
    init(gameInterface: GameRepositoryOutputInterface?,
         dataBaseReaderInterface : GameRepositoryReadInterface?,
         userInterface : UserInfoInterface?) {
        self.gameInterface = gameInterface
        self.dataBaseReaderInterface = dataBaseReaderInterface
        self.userInterface = userInterface
    }
}

extension GameGatewayOutput : GameGatewayOutputInterface {
    func updateState(state: GameState) async throws {
        if let _ = dataBaseReaderInterface?.getCurrentGame() {
            try await gameInterface?.updateState(state: state)
        }
    }
    
    func updatePawn(pawn: Pawn) async throws {
        if let currentGame = dataBaseReaderInterface?.getCurrentGame(),
           let currentUser = userInterface?.getUserInfo() {
            var playerType = PlayerType.player1
            var player : Player = Player.defaultValue
            
            if currentGame.player1.playerId == currentUser.userId {
                player = Player(name: currentGame.player1.name,
                                playerId: currentGame.player1.playerId,
                                pawnPosition: pawn,
                                walls: currentGame.player1.walls)
            } else {
                playerType = .player2
                player = Player(name: currentGame.player2.name,
                                playerId: currentGame.player2.playerId,
                                pawnPosition: pawn,
                                walls: currentGame.player2.walls)
            }
            
            let move = Move(playerName: player.name, pawnMove: pawn, wallMove: Wall.initValue)
            var currentMoves = currentGame.gameMoves
            currentMoves.append(move)

            let game = Game(created: currentGame.created,
                            state: currentGame.state,
                            player1: playerType == .player1 ? player : currentGame.player1,
                            player2: playerType == .player2 ? player : currentGame.player2,
                            lastMove: move,
                            gameMoves: currentMoves)
            
            try await gameInterface?.updateGame(game: game)
        }
    }
    
    func updateWall(wall: Wall) async throws {
        if let currentGame = dataBaseReaderInterface?.getCurrentGame(),
           let currentUser = userInterface?.getUserInfo() {
            var playerType = PlayerType.player1
            var player : Player = Player.defaultValue
            
            if currentGame.player1.playerId == currentUser.userId {
                var currentWalls = currentGame.player1.walls
                currentWalls.append(wall)
                
                player = Player(name: currentGame.player1.name,
                                playerId: currentGame.player1.playerId,
                                pawnPosition: currentGame.player1.pawnPosition,
                                walls: currentWalls)
            } else {
                playerType = .player2
                var currentWalls = currentGame.player2.walls
                currentWalls.append(wall)
                
                player = Player(name: currentGame.player2.name,
                                playerId: currentGame.player2.playerId,
                                pawnPosition: currentGame.player2.pawnPosition,
                                walls: currentWalls)
            }
            
            let move = Move(playerName: player.name, pawnMove: Pawn.defaultValue, wallMove: wall)
            var currentMoves = currentGame.gameMoves
            currentMoves.append(move)
                        
            let game = Game(created: currentGame.created,
                            state: currentGame.state,
                            player1: playerType == .player1 ? player : currentGame.player1,
                            player2: playerType == .player2 ? player : currentGame.player2,
                            lastMove: move,
                            gameMoves: currentMoves)
            
            try await gameInterface?.updateGame(game: game)
        }
    }
    
}
