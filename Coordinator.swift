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
        let vc = getBoardViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func getBoardViewController() -> BoardViewController {
        
        //Ouput
        let gameRepositoryOutput = MultiplayerOutputGameRepository(dbReader: gameDB)
        let gatewayOutput = GameGatewayOutput(gameInterface: gameRepositoryOutput,
                                              dataBaseReaderInterface: gameDB,
                                              userInterface: userDB)
        let validator = Validator(readerInterface: gameDB)
        
        
        let userCase = GameOutputUseCase(validator: validator, gatewayOutputInterface: gatewayOutput)
        
        //MatchMaking and Input
        let gameInputViewModel = GameInputViewModel()
        let gameInputUseCase = GameInputUseCase(viewModelListener: gameInputViewModel)
        let gameGatewayInput = GameGatewayInput(dataBaseWriterInterface: gameDB, controller: gameInputUseCase)
        let gameRepositoryInput = MultiplayerInputGameRepository(gatewayInputInterface: gameGatewayInput, localRepoWriter: gameDB, userInterface: userDB)
        let matchMakingUseCase = MatchMakingUseCase(gameInputInterface: gameRepositoryInput,
                                                    userInterface: userDB)


        
        
        //viewModel
        
        let viewModel = BoardViewModel(useCases: userCase, matchmakingUseCase: matchMakingUseCase)
        let viewController = BoardViewController(viewModel: viewModel, listener: gameInputViewModel)
        
        return viewController
    }
    
   
    
}
