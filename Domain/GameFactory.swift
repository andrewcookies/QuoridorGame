//
//  GameFactory.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 23/12/22.
//

import Foundation

protocol GameSettingsProtocol {
    
    var startPlayerPosition : Pawn { get }
    var startOppositePosition : Pawn { get }
    var winningCells : [Pawn] { get }
    
    func outOfBoard(pawn : Pawn) -> Bool
    func outOfBoard(wall : Wall) -> Bool
}

protocol GameFactoryProtocol {
    func updatePawn(pawn : Pawn) -> Result<Game,GameEvent>
    func updateWall(wall : Wall) -> Result<Game,GameEvent>
    func updateGame(game : Game)
    func getGame() -> Game
    func fetchAllowedCurrentPawn() -> [Pawn]
    func createGame() -> Game
    func getPlayerToJoinGame() -> Player
}

final class GameFactory {
    
    private var gameValidator : GameSettingsProtocol
    private var userInfo : UserInfoInterface
    private var currentGame : Game
    
    private var analyzedPawnForWallValidation : [Pawn]
    
    init(gameValidator : GameSettingsProtocol,
         userInfo: UserInfoInterface) {
        self.userInfo = userInfo
        self.gameValidator = gameValidator
        
        currentGame = Game.defaultValue
        analyzedPawnForWallValidation = []
    }
    
    private func validatePawnMove(pawn : Pawn) -> GameEvent {
        if gameValidator.winningCells.filter({ $0.position == pawn.position }).count > 0 {
            return .matchWon
        }
        return .noEvent
    }
    private func validateWall(wall : Wall) -> GameEvent {
        let orientation = wall.orientation
        let totalWalls = currentGame.getTotalWalls()
        
        //1.check out of bound
        if gameValidator.outOfBoard(wall: wall) {
            return .invalidWall
        }
        
        //2.check overlapped
        let wallsOverlapped = totalWalls.filter({ $0.orientation == orientation &&
            ($0.topLeftCell == wall.topLeftCell
             || $0.topLeftCell == wall.topRightCell
             || $0.topRightCell == wall.topLeftCell
             || $0.topLeftCell == wall.bottomLeftCell
             || $0.bottomLeftCell == wall.topLeftCell) })
        if wallsOverlapped.count > 0 {
            return .invalidWall
        }
        
        //3.check crossing
        let wallsCrossed = totalWalls.filter({ $0.orientation != orientation && $0.topLeftCell == wall.topLeftCell })
        if wallsCrossed.count > 0 {
            return .invalidWall
        }
        
        //4.check ring
        analyzedPawnForWallValidation.removeAll()
        let completeWalls = currentGame.getTotalWalls() + [wall]
        let player = currentGame.player1.playerId == userInfo.getUserInfo().userId ? currentGame.player1 : currentGame.player2
        
        if checkRing(pawn: player.pawnPosition, walls: completeWalls) == false {
            return .noEvent
        }
        
        return .invalidWall
    }
    
    func checkRing(pawn : Pawn, walls : [Wall]) -> Bool {
        GameLog.shared.debug(message: "checkRing \(pawn.position)", className: "GameFactory")
        if validatePawnMove(pawn: pawn) == .matchWon {
            return false
        }
        
        analyzedPawnForWallValidation.append(pawn)
        let allowedPawn = fetchAllowedPawn(pawn: pawn, walls: walls)
        
        for currentPawn in allowedPawn {
            if analyzedPawnForWallValidation.filter({ $0.position == currentPawn.position }).count == 0 {
                if checkRing(pawn: currentPawn, walls: walls) == false {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func fetchAllowedPawn(pawn : Pawn, walls : [Wall]) -> [Pawn] {
        var res = [Int]()
        
        let totalWall = walls
        let currentPosition = pawn.position
        
        if totalWall.contains(where: { ($0.topLeftCell == currentPosition || $0.topRightCell == currentPosition) && $0.orientation == .horizontal }) == false {
            let northPosition = currentPosition + bufferTopDownCell
            if gameValidator.outOfBoard(pawn: Pawn(position: northPosition)) == false {
                res.append(northPosition)
            }
        }
        
        if totalWall.contains(where: { ($0.bottomLeftCell == currentPosition || $0.bottomRightCell == currentPosition) && $0.orientation == .horizontal }) == false {
            let southPosition = currentPosition - bufferTopDownCell
            if gameValidator.outOfBoard(pawn: Pawn(position: southPosition)) == false {
                res.append(southPosition)
            }
        }
        
        if totalWall.contains(where: { ($0.bottomLeftCell == currentPosition || $0.topLeftCell == currentPosition) && $0.orientation == .vertical }) == false {
            let eastPosition = currentPosition - bufferLeftRightCell
            if gameValidator.outOfBoard(pawn: Pawn(position: eastPosition)) == false {
                res.append(eastPosition)
            }
        }
        
        if totalWall.contains(where: { ($0.bottomRightCell == currentPosition || $0.topRightCell == currentPosition) && $0.orientation == .vertical }) == false {
            let westPosition = currentPosition + bufferLeftRightCell
            if gameValidator.outOfBoard(pawn: Pawn(position: westPosition)) == false {
                res.append(westPosition)
            }
        }
        
        
        return res.map({ return Pawn(position: $0)})
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
    
    func fetchAllowedCurrentPawn() -> [Pawn] {
        let player = currentGame.player1.playerId == userInfo.getUserInfo().userId ? currentGame.player1 : currentGame.player2
        
        let pawns = fetchAllowedPawn(pawn: player.pawnPosition, walls: currentGame.getTotalWalls())
        return pawns
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
                            pawnPosition: Pawn.startOppositePlayer,
                            walls: [])
        return player
        
    }
}
