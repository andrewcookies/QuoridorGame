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
        
        let userRepo = resolveUserRepository()
        let multiplayerDataBaseRepository = resolveMultiplayerLocalDataRepository()
        let boardFactory = BoardFactory(userInfo: userRepo)
        let gameFactory = GameFactory(userInfo: userRepo)
        
        let outputDataLayer = resolveBoardOutpuDataLayer(localDataRepository: multiplayerDataBaseRepository)
        
        let outputUseCase = GameOutputUseCase(gameFactory: gameFactory, gameInterface: outputDataLayer)
       
        let inputViewModel = GameInputViewModel(boardFactory: boardFactory)
        let inputUseCase = GameInputUseCase(viewModelListener: inputViewModel, gameFactory: gameFactory)
        
        let inputDataLayer = resolveBoardInputDataLayer(localGameRepository: multiplayerDataBaseRepository, inputUseCase: inputUseCase)
        
        let matchMakingUseCase = MatchMakingUseCase(gameInputInterface: inputDataLayer, gameFactory: gameFactory)
        
        let boardViewModel = BoardViewModel(useCases: outputUseCase, matchmakingUseCase: matchMakingUseCase, boardFactory: boardFactory)
        let boardViewController = BoardViewController(viewModel: boardViewModel)
        
        boardViewModel.viewControllerInterface = boardViewController
        inputViewModel.viewControllerProtocol = boardViewController
        
        return boardViewController
    }
    
    //MARK: resoving clean components
    
    //DATA Layer
    private func resolveUserRepository() -> UserInfoInterface {
        //user data
        return UserRepository()
    }
    
    private func resolveMultiplayerLocalDataRepository() -> MultiplayerLocalRepositoryInterface {
        //store Game Multiplayer Info such as GameId
        return LocalGameRepository()
    }
    
    
   //Interfaces toward API Calls
    private func resolveBoardOutpuDataLayer(localDataRepository : MultiplayerLocalRepositoryInterface) -> GameRepositoryOutputInterface {
        return MultiplayerOutputGameRepository(dbReader: localDataRepository)
    }
    private func resolveBoardInputDataLayer(localGameRepository : MultiplayerLocalRepositoryInterface, inputUseCase : GameInputUseCaseProtocol) -> GameRepositoryInputInterface {
        return MultiplayerInputGameRepository(gameInputUseCase: inputUseCase, localRepoWriter: localGameRepository)
    }
        
    
    
    //MARK: Navigation Actions
    private func startGame() {
        let vc = getBoardViewController()
        navigationController?.popViewController(animated: false)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    
}
