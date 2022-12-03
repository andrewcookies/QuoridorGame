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
        //navigation..
        let vc = getBoardViewController()
        navigationController?.pushViewController(vc, animated: false)
        
    }
    
    private func getBoardViewController() -> BoardViewController {
        
        //Ouput
        let gamerepositoryOutput = MultiplayerOutputGameRepository()
        let gatewayOutput = GameOutputGateway(gameInterface: gamerepositoryOutput,
                                              dataBaseReaderInterface: gameDB,
                                              userInterface: userDB)
        let validator = Validator(readerInterface: gameDB)
        
        
        let userCase = GameUseCase(validator: validator, gatewayOutputInterface: gatewayOutput)
        
        //Listener
        let listenerViewModel = MatchMakingViewModel()
        
        //Input
        let gatewayInput = GameInputGateway(dataBaseWriterInterface: gameDB,
                                 controller: listenerViewModel)
        let gameRepositoryInput = MultiplayerInputGameRepository(gatewayInputInterface: gatewayInput)
        let matchMaking = MatchMakingUseCase(gameInputInterface: gameRepositoryInput,
                                             userInterface: userDB,
                                             dbWriter: gameDB)
        
        
        //viewModel
        
        let viewModel = BoardViewModel(useCases: userCase, matchmakingUseCase: matchMaking)
        let viewController = BoardViewController(viewModel: viewModel, listener: listenerViewModel)
        
        return viewController
    }
    
   
    
}
