//
//  Coordinator.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
import UIKit

enum MatchType {
    case demo
    case online
}

var matchType : MatchType = .online

final class Coordinator {
    
    private var navigationController : UINavigationController?
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = getLoginViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func getLoginViewController() -> LoginViewController {
        let userInfo = resolveUserRepository()
        let navigation = LoginViewNavigation(startGame: { [weak self] in
            self?.startGame(userInfo : userInfo)
        })
        let viewModel = LoginViewModel(userInterface: userInfo,
                                       navigation: navigation)
        let viewController = LoginViewController(viewModel: viewModel)
        return viewController
    }
    
    private func getBoardViewController(userInfo : UserInfoInterface) -> BoardViewController {
        
        let multiplayerDataBaseRepository = resolveMultiplayerLocalDataRepository()
        let boardFactory = BoardFactory(userInfo: userInfo)
        let gameFactory = GameFactory(gameValidator: boardFactory, userInfo: userInfo)
        
        let outputDataLayer = matchType == .demo ? DemoGameOutputRepository() : resolveBoardOutpuDataLayer(localDataRepository: multiplayerDataBaseRepository)
        
        let outputUseCase = GameOutputUseCase(gameFactory: gameFactory, gameInterface: outputDataLayer)
       
        let inputViewModel = GameInputViewModel(boardFactory: boardFactory)
        let inputUseCase = GameInputUseCase(viewModelListener: inputViewModel, gameFactory: gameFactory)
        
        let inputDataLayer = matchType == .demo ? DemoGameInputRepository(inputUseCase: inputUseCase) : resolveBoardInputDataLayer(localGameRepository: multiplayerDataBaseRepository, inputUseCase: inputUseCase, userInfo: userInfo)
        
        let matchMakingUseCase = MatchMakingUseCase(gameInputInterface: inputDataLayer, gameFactory: gameFactory)
        
        
        let navigation = BoardViewNavigation(close: { [weak self] in
            self?.closeView()
        })
        let boardViewModel = BoardViewModel(navigation: navigation,
                                            useCases: outputUseCase,
                                            matchmakingUseCase: matchMakingUseCase,
                                            boardFactory: boardFactory)
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
        return MultiplayerLocalStorageRepository()
    }
    
    
   //Interfaces toward API Calls
    private func resolveBoardOutpuDataLayer(localDataRepository : MultiplayerLocalRepositoryInterface) -> GameRepositoryOutputInterface {
        return MultiplayerOutputGameRepository(dbReader: localDataRepository)
    }
    private func resolveBoardInputDataLayer(localGameRepository : MultiplayerLocalRepositoryInterface,
                                            inputUseCase : GameInputUseCaseProtocol,
                                            userInfo : UserInfoInterface) -> GameRepositoryInputInterface {
        return MultiplayerInputGameRepository(gameInputUseCase: inputUseCase,
                                              localRepoWriter: localGameRepository,
                                              userInfo: userInfo)
    }
        
    
    
    //MARK: Navigation Actions
    private func startGame(userInfo : UserInfoInterface) {
        let vc = getBoardViewController(userInfo: userInfo)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.popViewController(animated: false)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func closeView(){
        navigationController?.popViewController(animated: false)
    }
    
    
}
