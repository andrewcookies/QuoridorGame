//
//  GameFactory.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 23/12/22.
//

import Foundation

protocol GameSettingsProtocol {
    var defaultGame : Game { get }
    var startPlayerPosition : Pawn { get }
    var startOppositePosition : Pawn { get }
    var startWall : Wall { get }
    var winningCells : [Pawn] { get }
    
    func nextNorthPosition(position : Int) -> Int
    func nextSouthPosition(position : Int) -> Int
    func nextEastPosition(position : Int) -> Int
    func nextWestPosition(position : Int) -> Int

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
        
        currentGame = gameValidator.defaultGame
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
        
        //0.check if player used all its walls
        let playerWalls = currentGame.player1.playerId == userInfo.getUserInfo().userId ? currentGame.player1.walls : currentGame.player2.walls
        if playerWalls.count > numberWallPerPlayer {
            GameLog.shared.debug(message: "validateWall \(playerWalls.count) walls", className: "GameFactory")
            return .invalidWall
        }
        
        //1.check out of bound
        if gameValidator.outOfBoard(wall: wall) {
            GameLog.shared.debug(message: "validateWall outOfBound walls", className: "GameFactory")
            return .invalidWall
        }
        
        //2.check overlapped
        var wallsOverlapped : [Wall]?
        if orientation == .horizontal {
            wallsOverlapped = totalWalls.filter({ $0.orientation == orientation &&
                ($0.topLeftCell == wall.topLeftCell
                 || $0.topLeftCell == wall.topRightCell
                 || $0.topRightCell == wall.topLeftCell) })
        } else {
            wallsOverlapped = totalWalls.filter({ $0.orientation == orientation &&
                ($0.topLeftCell == wall.topLeftCell
                 || $0.topLeftCell == wall.bottomLeftCell
                 || $0.bottomLeftCell == wall.topLeftCell) })
        }
        
        if wallsOverlapped?.count ?? 1 > 0  {
            GameLog.shared.debug(message: "validateWall overlapped walls", className: "GameFactory")
            return .invalidWall
        }
       
        //3.check crossing
        let wallsCrossed = totalWalls.filter({ $0.orientation != orientation && $0.topLeftCell == wall.topLeftCell })
        if wallsCrossed.count > 0 {
            GameLog.shared.debug(message: "validateWall crossing walls", className: "GameFactory")
            return .invalidWall
        }
        
        //4.check ring
        analyzedPawnForWallValidation.removeAll()
        let completeWalls = currentGame.getTotalWalls() + [wall]
        let player = currentGame.player1.playerId == userInfo.getUserInfo().userId ? currentGame.player1 : currentGame.player2
        
        if checkRing(pawn: player.pawnPosition, walls: completeWalls) == false {
            return .noEvent
        }
        
        GameLog.shared.debug(message: "validateWall ring found walls", className: "GameFactory")
        return .invalidWall
    }
    
    func checkRing(pawn : Pawn, walls : [Wall]) -> Bool {
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
            let northPosition = gameValidator.nextNorthPosition(position: currentPosition)
            if gameValidator.outOfBoard(pawn: Pawn(position: northPosition)) == false {
                res.append(northPosition)
            }
        }
        
        if totalWall.contains(where: { ($0.bottomLeftCell == currentPosition || $0.bottomRightCell == currentPosition) && $0.orientation == .horizontal }) == false {
            let southPosition = gameValidator.nextSouthPosition(position: currentPosition)
            if gameValidator.outOfBoard(pawn: Pawn(position: southPosition)) == false {
                res.append(southPosition)
            }
        }
        
        if totalWall.contains(where: { ($0.bottomLeftCell == currentPosition || $0.topLeftCell == currentPosition) && $0.orientation == .vertical }) == false {
            let eastPosition = gameValidator.nextEastPosition(position: currentPosition)
            if gameValidator.outOfBoard(pawn: Pawn(position: eastPosition)) == false {
                res.append(eastPosition)
            }
        }
        
        if totalWall.contains(where: { ($0.bottomRightCell == currentPosition || $0.topRightCell == currentPosition) && $0.orientation == .vertical }) == false {
            let westPosition = gameValidator.nextWestPosition(position: currentPosition)
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
        var player : Player = Player(name: currentGame.player1.name,
                                     playerId: currentGame.player1.playerId,
                                     pawnPosition: pawn,
                                     walls: currentGame.player1.walls)
        
        if currentGame.player1.playerId != currentUser.userId {
            playerType = .player2
            player = Player(name: currentGame.player2.name,
                            playerId: currentGame.player2.playerId,
                            pawnPosition: pawn,
                            walls: currentGame.player2.walls)
        }
        
        let move = Move(playerId: player.playerId, pawnMove: pawn, wallMove: gameValidator.startWall, moveType: .movePawn)
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
        var player : Player = Player(name: currentGame.player1.name,
                                     playerId: currentGame.player1.playerId,
                                     pawnPosition: currentGame.player1.pawnPosition,
                                     walls: currentGame.player1.walls + [wall])
        
        
        if currentGame.player1.playerId != currentUser.userId {
            playerType = .player2
            player = Player(name: currentGame.player2.name,
                            playerId: currentGame.player2.playerId,
                            pawnPosition: currentGame.player2.pawnPosition,
                            walls: currentGame.player2.walls + [wall])
        }
        
        let move = Move(playerId: player.playerId, pawnMove: Pawn(position: pawnNilMove), wallMove: wall, moveType: .insertWall)
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
                            pawnPosition: gameValidator.startPlayerPosition,
                            walls: [])
        let defaultOpponentPlayer = Player(name: defaultPlayerName, playerId: defaultPlayerId, pawnPosition: Pawn(position: pawnNilMove), walls: [])
        
        let move = Move(playerId: player.playerId, pawnMove: player.pawnPosition, wallMove: player.walls.last ?? gameValidator.startWall, moveType: .movePawn)
        let timestamp = Double((Date().timeIntervalSince1970 * 1000.0).rounded())
        let game = Game(created: timestamp,
                        state: .waiting,
                        player1: player,
                        player2: defaultOpponentPlayer,
                        lastMove: move,
                        gameMoves: [move])
        return game
    }
    
    
    func getPlayerToJoinGame() -> Player {
        let player = Player(name: userInfo.getUserInfo().name,
                            playerId: userInfo.getUserInfo().userId,
                            pawnPosition: gameValidator.startOppositePosition,
                            walls: [])
        return player
        
    }
}
