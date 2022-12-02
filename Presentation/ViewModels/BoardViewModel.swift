//
//  BoardViewModel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation
import Combine

protocol BoardViewModelProtocol {
    func movePawn(index : Int)
    func insertWall(index : Int)
    func initializeMatch()
    
    var boardListener : Published<Game>.Publisher { get }
}


final class BoardViewModel {
    
    private var useCases : GameUseCaseProtocol?
    private var subscribers: [AnyCancellable] = []

    @Published private var currentGame : Game = Game.defaultValue
    
    init(useCases: GameUseCaseProtocol?) {
        self.useCases = useCases
        setupObserver()
    }
    
    private func setupObserver(){
        useCases?.match.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] game in
            guard let self = self else { return }
            self.currentGame = game
        }).store(in: &subscribers)
    }
    
}

extension BoardViewModel : BoardViewModelProtocol {
    
    var boardListener: Published<Game>.Publisher {
        $currentGame
    }
    
    func movePawn(index: Int) {
        let p = Pawn(position: index)
        Task {
            let res = await useCases?.movePawn(newPawn: p)
        }
    }
    
    func insertWall(index: Int) {
        let w = Wall(orientation: .horizontal, position: .bottom, topLeftCell: index)
        Task {
            let res = await useCases?.insertWall(wall: w)
        }
    }
    
    func initializeMatch() {
        Task {
            let res = await useCases?.initMatch()
        }
    }
    
    
}
