//
//  Coordinator.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
import UIKit

enum MatchType {
    case local
    case online
}

final class Coordinator {
    
    private var navigationController : UINavigationController?
    private let gameDB = DataBaseRepository()
    private let userDB =  UserRepository()
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = getLoginViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func getLoginViewController() -> LoginViewController {
        let navigation = LoginViewNavigation(startGame: { [weak self] in
            self?.startGame()
        })
        let viewModel = LoginViewModel(userInterface: userDB, navigation: navigation)
        let viewController = LoginViewController(viewModel: viewModel)
        return viewController
    }
    
    private func getBoardViewController() -> BoardViewController {
        
        //Ouput
        /*
        let gameRepositoryOutput = MultiplayerOutputGameRepository(dbReader: gameDB)
        let gatewayOutput = GameGatewayOutput(gameInterface: gameRepositoryOutput,
                                              dataBaseReaderInterface: gameDB,
                                              userInterface: userDB)
        let validator = Validator(readerInterface: gameDB, userInterface: userDB)
        
        
        let userCase = GameOutputUseCase(validator: validator, gatewayOutputInterface: gatewayOutput)
        
        //MatchMaking and Input
        let boardFactory = BoardFactory(userInfo: userDB)
        let gameInputViewModel = GameInputViewModel(boardFactory: boardFactory)
        let gameInputUseCase = GameInputUseCase(viewModelListener: gameInputViewModel)
        
        
        let gameGatewayInput = GameGatewayInput(dataBaseWriterInterface: gameDB, controller: gameInputUseCase)
        let gameRepositoryInput = MultiplayerInputGameRepository(gatewayInputInterface: gameGatewayInput,
                                                                 localRepoWriter: gameDB,
                                                                 userInterface: userDB)
        let matchMakingUseCase = MatchMakingUseCase(gameInputInterface: gameRepositoryInput,
                                                    userInterface: userDB)


        
        
        //viewModel
        
        let viewModel = BoardViewModel(useCases: userCase, matchmakingUseCase: matchMakingUseCase, boardFactory: boardFactory)
        let viewController = BoardViewController(viewModel: viewModel)
        
        gameInputViewModel.viewControllerProtocol = viewController
        */
        
        let databaseRepo = resolveDataBaseRepository()
        let userRepo = resolveUserRepository()
        let multiplayerDataBaseRepository = resolveMultiplayerLocalDataRepository()
        
        
        let outputDataLayer = resolveBoardOutpuDataLayer(localDataRepository : multiplayerDataBaseRepository)
        
        let outputUseCase = resolveBoardOutputDomainLayer(userDataBase : userRepo, gameDataBase : databaseRepo, dataLayerInterface : outputDataLayer)
        
        let gameInputUseCase = resolveBoardInputDomainLayer(userInterface: userRepo)
        
        let matchMakingUseCase = resolveMatchMakingUseCase(gameInputRepository: databaseRepo, userInterface: userRepo, useCase: gameInputUseCase, repoWriteInterface: <#T##GameRepositoryWriteInterface#>)
        
        return UIViewController()
    }
    
    //MARK: resoving clean components
    
    //DATA Layer
    private func resolveUserRepository() -> UserRepository {
        //user data
        return UserRepository()
    }
    
    private func resolveMultiplayerLocalDataRepository() -> LocalGameRepository {
        //store Game Multiplayer Info such as GameId
        return LocalGameRepository()
    }
    
    private func resolveDataBaseRepository() -> DataBaseRepository {
        //store game object coming from Data Layer
        return DataBaseRepository()
    }
    
    
   
    private func resolveBoardOutpuDataLayer(localDataRepository : MultiplayerLocalRepositoryInterface) -> MultiplayerOutputGameRepository {
        return MultiplayerOutputGameRepository(dbReader: localDataRepository)
    }
    private func resolveBoardInputDataLayer(dataBaseRepository : DataBaseRepository, inputUseCase : GameInputUseCaseProtocol) -> MultiplayerOutputGameRepository {
        let gateway = GameGatewayInput(dataBaseWriterInterface: dataBaseRepository, controller: inputUseCase)
        return MultiplayerInputGameRepository(gatewayInputInterface: <#T##GameGatewayInputInterface#>, localRepoWriter: <#T##MultiplayerLocalRepositoryInterface?#>, userInterface: <#T##UserInfoInterface?#>)
    }
        
    //DOMAIN LAYER
    
    private func resolveBoardOutputDomainLayer(userDataBase : UserInfoInterface, gameDataBase : GameRepositoryReadInterface, dataLayerInterface : GameRepositoryOutputInterface ) -> GameOutputUseCase {
        
        let validator = Validator(readerInterface: gameDataBase, userInterface: userDataBase)
        
        let gatewayOutput = GameGatewayOutput(gameInterface: dataLayerInterface, dataBaseReaderInterface: gameDataBase, userInterface: userDataBase)
        
        let useCase = GameOutputUseCase(validator: validator, gatewayOutputInterface: gatewayOutput)
        
        return useCase
    }
    
    private func resolveBoardInputDomainLayer(userInterface : UserInfoInterface) -> GameInputUseCase {
        let boardFactory = BoardFactory(userInfo: userInterface)
        let gameInputViewModel = GameInputViewModel(boardFactory: boardFactory)
        let gameInputUseCase = GameInputUseCase(viewModelListener: gameInputViewModel)
        
        return gameInputUseCase
    }
    
    private func resolveMatchMakingUseCase( gameInputRepository : LocalGameRepository,
                                            userInterface : UserInfoInterface,
                                            useCase : GameInputUseCaseProtocol,
                                            repoWriteInterface : GameRepositoryWriteInterface ) -> MatchMakingUseCase {
        
        
        let gameGatewayInput = GameGatewayInput(dataBaseWriterInterface: repoWriteInterface, controller: useCase)
        let gameRepositoryInput = MultiplayerInputGameRepository(gatewayInputInterface: gameGatewayInput,
                                                                 localRepoWriter: gameInputRepository,
                                                                 userInterface: userInterface)
        let matchMakingUseCase = MatchMakingUseCase(gameInputInterface: gameRepositoryInput,
                                                    userInterface: userDB)
        
    }
    
    //PRESENTATION LAYER
    
    private func resolvePresentationLayer() -> BoardViewController {
        
        
        
    }
    
    
    
    
    //MARK: Navigation Actions
    private func startGame() {
        let vc = getBoardViewController()
        navigationController?.popViewController(animated: false)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    
}
