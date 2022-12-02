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
    private let gameDB = DataBaseRepository()
    private let userDB =  UserRepository()
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    func start() {
        //navigation...

        
        let gameInterface = OnlineGameRepository(userInterface: userDB,
                                                 readerInterface: gameDB)
        
        let validator = Validator(readerInterface: gameDB)

        
        let useCase = GameUseCase(gameRepoWriterInterface: gameDB,
                                  validator: validator,
                                  gameInterface: gameInterface)
        
        let viewModel = BoardViewModel(useCases: useCase)
        let viewContoller = BoardViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewContoller, animated: false)
        
    }
    
    
    
}
