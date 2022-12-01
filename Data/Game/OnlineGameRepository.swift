//
//  OnlineGameRepository.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 29/11/22.
//

import Foundation

final class OnlineGameRepository {
    
    @Published private var localBoard : Board = Board()

}


extension OnlineGameRepository : GameInterface {
    var boardListener: Published<Board>.Publisher {
        $localBoard
    }
    
    func updatePawn(pawn: Pawn) async throws {
        //TODO:
    }
    
    func updateWalls(wall: Wall) async throws {
        //TODO
    }
    
    
    func searchMatch() async throws {
        //TODOD:
    }
    
}
