//
//  GameFactory.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 23/12/22.
//

import Foundation

protocol GameFactoryProtocol {
    func updatePawn(pawn : Pawn) -> Result<Game,GameEvent>
    func updateWall(wall : Wall) -> Result<Game,GameEvent>
    func updateGame(game : Game)
    func getGame() -> Game
    func fetchAllowedPawn() -> [Pawn]
    func createGame() -> Game
    func getPlayerToJoinGame() -> Player
}

final class GameFactory {
    
    private var userInfo : UserInfoInterface
    private var currentGame : Game
    
    init(userInfo: UserInfoInterface) {
        self.userInfo = userInfo
        currentGame = Game.defaultValue
    }
    
    private func validatePawnMove(pawn : Pawn) -> GameEvent {
        //Check if match is won
        return .noEvent
    }
    private func validateWall(wall : Wall) -> GameEvent {
        return .noEvent
    }
}

extension GameFactory : GameFactoryProtocol {
    func updatePawn(pawn: Pawn) -> Result<Game, GameEvent> {
        
        let validation = validatePawnMove(pawn: pawn)
        if validation != .noEvent {
            return .failure(validation)
        }
        
        
        let currentUser = userInfo.getUserInfo()
        var playerType = PlayerType.player1
        var player : Player = Player.startPlayerValue
        
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
        
        let move = Move(playerId: player.playerId, pawnMove: pawn, wallMove: Wall.initValue, moveType: .movePawn)
        var currentMoves = currentGame.gameMoves
        currentMoves.append(move)
        
        let game = Game(created: currentGame.created,
                        state: currentGame.state,
                        player1: playerType == .player1 ? player : currentGame.player1,
                        player2: playerType == .player2 ? player : currentGame.player2,
                        lastMove: move,
                        gameMoves: currentMoves)
        
        return .success(game)
    }
    
    func updateWall(wall: Wall) -> Result<Game, GameEvent> {
        
        let validation = validateWall(wall: wall)
        if validation != .noEvent {
            return .failure(validation)
        }
        
        let currentUser = userInfo.getUserInfo()
        var playerType = PlayerType.player1
        var player : Player = Player.startPlayerValue
        
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
        
        let move = Move(playerId: player.playerId, pawnMove: Pawn.defaultValue, wallMove: wall, moveType: .insertWall)
        var currentMoves = currentGame.gameMoves
        currentMoves.append(move)
        
        let game = Game(created: currentGame.created,
                        state: currentGame.state,
                        player1: playerType == .player1 ? player : currentGame.player1,
                        player2: playerType == .player2 ? player : currentGame.player2,
                        lastMove: move,
                        gameMoves: currentMoves)
        
        return .success(game)
    }
    
    func updateGame(game: Game) {
        currentGame = game
    }

    func getGame() -> Game {
        return currentGame
    }
    
    func fetchAllowedPawn() -> [Pawn] {
        let game = currentGame
        let player = game.player1.playerId == userInfo.getUserInfo().userId ? game.player1 : game.player2
        var res = [Int]()
        
        let totalWall = game.getTotalWalls()
        let currentPosition = player.pawnPosition.position
        
        let northPosition = currentPosition + bufferTopDownCell
        if totalWall.contains(where: { ($0.topLeftCell == northPosition || $0.topRightCell == northPosition) && $0.orientation == .horizontal }) == false {
            if northPosition > 0 && northPosition < 89 {
                res.append(northPosition)
            }
        }
        
        let southPosition = currentPosition - bufferTopDownCell
        if totalWall.contains(where: { ($0.bottomLeftCell == southPosition || $0.bottomRightCell == southPosition) && $0.orientation == .horizontal }) == false {
            if northPosition > 0 && northPosition < 89 {
                res.append(southPosition)
            }
        }
        
        let eastPosition = currentPosition - bufferLeftRightCell
        if totalWall.contains(where: { ($0.bottomLeftCell == eastPosition || $0.topLeftCell == southPosition) && $0.orientation == .vertical }) == false {
            if leftRightBorder.contains(eastPosition) == false {
                res.append(eastPosition)
            }
        }
        
        let westPosition = currentPosition + bufferLeftRightCell
        if totalWall.contains(where: { ($0.bottomRightCell == westPosition || $0.topRightCell == westPosition) && $0.orientation == .vertical }) == false {
            if leftRightBorder.contains(westPosition) == false {
                res.append(eastPosition)
            }
        }
        
        
        
        return res.map({ return Pawn(position: $0)})
    }
    
    func createGame() -> Game {
        let player = Player(name: userInfo.getUserInfo().name,
                            playerId: userInfo.getUserInfo().userId,
                            pawnPosition: Pawn.startValue,
                            walls: [])
        let move = Move(playerId: player.playerId, pawnMove: player.pawnPosition, wallMove: player.walls.last ?? Wall.initValue, moveType: .movePawn)
        let timestamp = Double((Date().timeIntervalSince1970 * 1000.0).rounded())
        let game = Game(created: timestamp,
                        state: .waiting,
                        player1: player,
                        player2: Player.startOpponentValue,
                        lastMove: move,
                        gameMoves: [move])
        return game
    }
    
    
    func getPlayerToJoinGame() -> Player {
        let player = Player(name: userInfo.getUserInfo().name,
                            playerId: userInfo.getUserInfo().userId,
                            pawnPosition: Pawn.startValue,
                            walls: [])
        return player
        
    }
}
