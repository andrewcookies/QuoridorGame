//
//  Coordinator.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
import UIKit

final class Coordinator {
    
    private var navigationController : UINavigationController?
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    func start() {
        //navigation...
        
        let gameInterface = OnlineGameRepository()
        let validator = Validator()
        let boardRepository = BoardRespository(validator: validator)

        
        let useCase = GameUseCase(userInfoInterface: nil,
                                  boardInterface: boardRepository,
                                  gameInterface: gameInterface)
        
        let viewModel = BoardViewModel(useCases: useCase)
        let viewContoller = BoardViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewContoller, animated: false)
        
    }
    
    
    
}
